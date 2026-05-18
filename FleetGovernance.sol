// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DecentralizedFleetGovernance {
    
    address public owner;
    uint256 public taskCounter;

    struct Task {
        uint256 taskId;
        address assignedRobot;
        address secondaryRobot; // قالب للتعاون المشترك بين روبوتين لرفع التقييم
        uint256 payload;
        uint256 sensorTarget;   // القيمة المستهدفة مكبرة (x10^7)
        string metadataURI;     // رابط الـ IPFS المخزن عليه الداتا التقيلة
        bool isClosed;
    }

    // --- بوابات سجلات البيانات On-Chain ---
    mapping(address => uint128) public robotCapabilities; // الباب الأول: الـ Bitmask
    mapping(address => bool) public isVetted;             // الباب الأول: فحص الاعتماد
    mapping(address => uint256) public activeTask;        // الباب الثاني: درع التزامن
    mapping(address => uint8) public robotBattery;        // شرط إضافي متقدم: نسبة البطارية (0-100)
    
    mapping(uint256 => Task) public tasks;

    // --- الـ Events لتتبع الحركة على الشبكة ---
    event RobotRegistered(address indexed robot, uint128 capabilities);
    event TaskAssigned(uint256 indexed taskId, address indexed robot, string metadataURI);
    event TaskCompleted(uint256 indexed taskId, address indexed robot, bytes32 zkProofHash);
    event BatteryUpdated(address indexed robot, uint8 newBattery);

    modifier onlyOwner() {
        require(msg.sender == owner, "CRITICAL ERROR: Administrative Access Denied!");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // ========================================================
    // 1. LOGICAL ACTUATOR FUNCTIONS (Administrative Layer)
    // ========================================================

    function registerRobot(address _robot, uint128 _capabilities, uint8 _initialBattery) external onlyOwner {
        require(_robot != address(0), "Invalid robot address.");
        require(_initialBattery <= 100, "Battery range overflow.");
        
        isVetted[_robot] = true;
        robotCapabilities[_robot] = _capabilities;
        robotBattery[_robot] = _initialBattery;

        emit RobotRegistered(_robot, _capabilities);
        emit BatteryUpdated(_robot, _initialBattery);
    }

    function updateRobotBattery(address _robot, uint8 _newBattery) external {
        require(msg.sender == owner || msg.sender == _robot, "Unauthorized telemetry source.");
        require(_newBattery <= 100, "Battery range overflow.");
        robotBattery[_robot] = _newBattery;
        
        emit BatteryUpdated(_robot, _newBattery);
    }

    // ========================================================
    // 2. BEHAVIORAL TASK LOGIC (Operational Layer)
    // ========================================================

    function assignTask(
        address _targetRobot,
        address _secondaryRobot, 
        uint256 _payload,
        uint256 _sensorTarget,   
        string calldata _metadataURI
    ) external onlyOwner {
        
        // [CHECKPOINT 1]: التأكد أن الروبوت معتمد ومسجل في الأسطول
        require(isVetted[_targetRobot], "CHECKPOINT 1 FAILED: Unvetted Robot Blocked!");
        
        // [ADVANCED CONSTRAINT]: فحص مستوى أمان الطاقة والبطارية قبل الحركة
        require(robotBattery[_targetRobot] >= 20, "DEPLOYMENT REJECTED: Robot Battery below critical limits!");

        // [CHECKPOINT 2]: تفعيل درع التزامن لمنع التضارب وحجز الروبوت مرتين
        require(activeTask[_targetRobot] == 0, "CHECKPOINT 2 FAILED: Race Condition Detected - Robot Busy!");

        taskCounter++;
        
        tasks[taskCounter] = Task({
            taskId: taskCounter,
            assignedRobot: _targetRobot,
            secondaryRobot: _secondaryRobot,
            payload: _payload,
            sensorTarget: _sensorTarget,
            metadataURI: _metadataURI,
            isClosed: false
        });

        // قفل حالة الروبوت وتوصيله بالمهمة الحالية
        activeTask[_targetRobot] = taskCounter;

        emit TaskAssigned(taskCounter, _targetRobot, _metadataURI);
    }

    // [CHECKPOINT 3]: بوابة فحص الإثبات وإغلاق المهمة
    function verifyAndCloseTask(
        uint256 _taskId, 
        uint256 _scaledSensorReading, 
        bytes32 _zkProofHash          
    ) external {
        Task storage task = tasks[_taskId];

        require(!task.isClosed, "Execution fault: Task already finalized.");

        // [CHECKPOINT 3]: مطابقة هوية المرسل الحالية مع الروبوت المسؤول لمنع التزوير
        require(msg.sender == task.assignedRobot || msg.sender == task.secondaryRobot, "CHECKPOINT 3 FAILED: Mismatched Completion!");

        // [COMPUTATIONAL PRECISION]: فحص الدقة الحسابية باستخدام الـ Epsilon Threshold
        uint256 epsilonThreshold = 50000; 
        
        bool precisionPassed = false;
        if (_scaledSensorReading >= task.sensorTarget) {
            precisionPassed = (_scaledSensorReading - task.sensorTarget) <= epsilonThreshold;
        } else {
            precisionPassed = (task.sensorTarget - _scaledSensorReading) <= epsilonThreshold;
        }
        
        require(precisionPassed, "MATHEMATICAL FAULT: Sensor verification falls outside safe Epsilon threshold.");

        // تحديث حالة السيستم بنجاح
        task.isClosed = true;
        
        // تحرير الروبوتات وفتح الـ Concurrency Lock ليرجع (0) وجاهز للمهام القادمة
        activeTask[task.assignedRobot] = 0;
        if(task.secondaryRobot != address(0)) {
            activeTask[task.secondaryRobot] = 0;
        }

        emit TaskCompleted(_taskId, msg.sender, _zkProofHash);
    }
}
