# RISC-V-32I-Single-Cycle-CPU
### RISC-V 32I Single Cycle CPU는 RISC-V 명령어 집합 구조(ISA) 중 가장 기본이 되는 32비트 정수형(Integer) 명령어 셋을 처리하는 프로세서이다.

## RISC-V 개요
<img width="784" height="364" alt="Image" src="https://github.com/user-attachments/assets/380a72e3-1853-4835-b1b1-2a10f4255773" />
<br>

## RISC-V Instruction Set
<img width="894" height="276" alt="Image" src="https://github.com/user-attachments/assets/73a5819d-9a3c-403c-bb50-da83c7464945" />
<img width="1498" height="922" alt="Image" src="https://github.com/user-attachments/assets/613a6f4d-0243-456f-893c-e0e4177eca6e" />
<br>

## RISC-V Block Diagram
<img width="1008" height="531" alt="Image" src="https://github.com/user-attachments/assets/bb8bcf95-d8de-40e1-86e6-dac2f6b1624a" />
<br>

## 특징
### 1. 동작 방식
#### 모든 명령어가 정확히 하나의 클록 사이클에 완료된다.
#### Fetch → Decode → Execute → Memory → Write Back 단계가 한 사이클 내에 순차적으로 진행된다.
<img width="400" height="188" alt="Image" src="https://github.com/user-attachments/assets/f7521963-f8c7-4fa3-8c9a-ef782753ef16" />
<br>

### 2. 주요 특징
#### 클록 주기 : 가장 느린 명령어(일반적으로 load)의 실행 시간에 맞춰 클록 주기가 결정된다.
#### 하드웨어 구조 : 각 단계마다 별도의 하드웨어 유닛이 필요하다. (예: 별도의 명령어 메모리와 데이터 메모리, 여러 개의 ALU)
#### CPI (Cycles Per Instruction) : 항상 1이다.
#### 제어 유닛 (Control Unit)의 특징 :
##### Combinational Logic: 멀티 사이클 프로세서가 FSM(Finite State Machine)을 사용하는 것과 달리, 싱글 사이클은 현재 명령어의 Opcode와 Funct 필드만 보고 즉시 모든 제어 신호(ALUOp, RegWrite, MemRead 등)를 생성하는 조합 회로로 구성된다. -> 단순하고 직관적임
#### 데이터패스(Datapath) :
##### - IF (Instruction Fetch): PC(Program Counter)가 가리키는 주소의 명령어 메모리에서 명령어를 가져옵니다. 동시에 PC는 PC + 4로 업데이트된다.
##### - ID (Instruction Decode): 가져온 명령어를 해석하여 레지스터 파일에서 소스 레지스터(rs1, rs2) 값을 읽고, Control Unit이 제어 신호를 생성한다.
##### - EX (Execute): ALU가 연산을 수행하거나, 주소 계산(Load/Store의 경우), 분기 조건 비교(Branch의 경우)를 수행한다.
##### - MEM (Memory Access): Load/Store 명령어인 경우 데이터 메모리에 접근하여 값을 읽거나 쓰기 동작을 수행한다. (R-type 등은 이 단계 패스)
##### - WB (Write Back): 연산 결과나 메모리에서 읽은 값을 레지스터 파일(rd)에 쓴다.
<br>

### 3. 명령어별 동작
#### R-type 명령어
<img width="699" height="395" alt="Image" src="https://github.com/user-attachments/assets/8c3b1ee5-7e4f-402e-9524-19252ec24b81" />
<img width="768" height="407" alt="Image" src="https://github.com/user-attachments/assets/43a21b29-a690-4821-9e1f-e1fbd5c52831" />

### 4. 장단점
#### [장점]
##### 구현이 단순하고 이해하기 쉽다.
##### 제어 로직이 간단하다.
##### 예측 가능한 타이밍을 가진다.

#### [단점]
##### 클록 주기가 길어 전체 성능이 낮다.
##### 하드웨어 활용도가 낮다. (각 사이클마다 일부 유닛만 사용)
##### 자원 낭비가 심함. (ALU, 메모리 등이 중복 배치)
