# DecodeLabs Internship - Robotics & Automation

Welcome to my official repository documenting my technical tasks and projects during the Robotics and Automation Internship at **DecodeLabs**. This repository serves as a portfolio demonstrating the practical application of robotics control algorithms, simulation environments, and computer vision systems.

---

## 📌 Executive Summary
During this internship, the focus was placed on bridging the gap between hardware control logic and intelligent software automation. The workload is divided into two major foundational projects:
1. **Project 1:** Robotics Kinematics & Simulation Control.
2. **Project 2:** Automated Vision-Based Industrial Quality Inspection.
## 🛠️ Project 1: Robotics Control & Simulation System
### Overview
This project focuses on designing and simulating robust control systems for robotic manipulators. It implements forward/inverse kinematics and trajectory planning to ensure precise industrial automation tasks.
### Key Features
* **Kinematics Engine:** Computes joint angles required for precise end-effector positioning.
* **Simulation Environment:** Validates robotic paths and collision avoidance profiles before deployment.
* **Control Loop Integration:** Simulates feedback loops to minimize error tracking during high-speed operations.
### Tech Stack
* Python / MATLAB (Control Logic)
* Robot Operating System (ROS) / Webots / CoppeliaSim (Simulation Environment)
## ⚙️ Project 2: Automated Industrial Gear Inspection System
### Overview
An automated quality control pipeline designed for production lines to inspect mechanical gears. Utilizing advanced computer vision techniques, the system distinguishes between healthy components (`PASS`) and defective/cracked components (`FAIL`) autonomously.
### Key Features
* **Robust Image Preprocessing:** Integrates adaptive thresholding (`Otsu's Binarization`) and Gaussian blurring to eliminate background noise and adapt to dynamic industrial lighting.
* **Geometric Feature Extraction:** Leverages contour detection algorithms (`findContours`) to map out exact gear boundaries.
* **Teeth Integrity Verification:** Uses polygon approximation (`approxPolyDP`) and bounding box dimensions to count and analyze gear teeth profiles for structural anomalies.
* **Automated Decision Tree:** Flags defects instantly and saves labeled evaluation frames for structural auditing.
### System Workflow
1. **Input:** Captures high-resolution images of gears (supports diverse formats including JPG, PNG, and AVIF).
2. **Filtering:** Conversions to Grayscale followed by a $9 \times 9$ Gaussian Kernel filter.
3. **Segmentation:** Binarization isolates the foreground metallic gear from complex backgrounds.
4. **Analysis & Verdict:** Geometric calculations evaluate the structure, printing a clear `STATUS: PASS` or `STATUS: FAIL` bounding box on the output frame.
### Tech Stack
* **Language:** Python 3.x
* **Core Libraries:** OpenCV (`cv2`), NumPy, Pillow (`PIL`)

## 📂 Repository Structure
```directory
├── Project_1_Robotics_Control/
│   ├── simulation/
│   └── scripts/
├── Project_2_Gear_Inspection/
│   ├── dataset/                 # Raw test gear images
│   ├── inspection_results/      # Labeled output verified images
│   └── final_gate.py            # Main execution pipeline
└── README.md                    # Main portfolio documentation
