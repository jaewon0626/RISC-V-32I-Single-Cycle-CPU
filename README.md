# RISC-V-32I-Single-Cycle-CPU
### RISC-V 32I Single Cycle CPU는 RISC-V 명령어 집합 구조(ISA) 중 가장 기본이 되는 32비트 정수형(Integer) 명령어 셋을 처리하는 프로세서로, 하나의 명령어를 처리하는 데 정확히 1 클럭 사이클이 소요되는 특징이 있다.

## RISC-V 개요
<img width="784" height="364" alt="Image" src="https://github.com/user-attachments/assets/380a72e3-1853-4835-b1b1-2a10f4255773" />
<br>

## RISC-V Instruction Set
<img width="894" height="276" alt="Image" src="https://github.com/user-attachments/assets/73a5819d-9a3c-403c-bb50-da83c7464945" />
<br>

## RISC-V Block Diagram
<img width="1008" height="531" alt="Image" src="https://github.com/user-attachments/assets/bb8bcf95-d8de-40e1-86e6-dac2f6b1624a" />
<br>

## 특징
### 1. 핵심 개념: CPI = 1Cycles Per Instruction 
#### (CPI): 모든 명령어(Load, Store, Branch, R-type 등)가 단 1 사이클 안에 인출(Fetch)부터 실행(Execute), 라이트백(Write-back)까지 동작한다.
#### 이 때문에 클럭의 주기($T_{clk}$)는 수행 시간이 가장 긴 명령어(보통 Load 명령어)의 지연 시간(Critical Path)에 맞춰 결정된다. -> 시간이 오래 걸림
<br>

### 2. 데이터패스(Datapath) 
#### - IF (Instruction Fetch): PC(Program Counter)가 가리키는 주소의 명령어 메모리에서 명령어를 가져옵니다. 동시에 PC는 PC + 4로 업데이트된다.
#### - ID (Instruction Decode): 가져온 명령어를 해석하여 레지스터 파일에서 소스 레지스터(rs1, rs2) 값을 읽고, Control Unit이 제어 신호를 생성한다.
#### - EX (Execute): ALU가 연산을 수행하거나, 주소 계산(Load/Store의 경우), 분기 조건 비교(Branch의 경우)를 수행한다.
#### - MEM (Memory Access): Load/Store 명령어인 경우 데이터 메모리에 접근하여 값을 읽거나 쓰기 동작을 수행한다. (R-type 등은 이 단계 패스)
#### - WB (Write Back): 연산 결과나 메모리에서 읽은 값을 레지스터 파일(rd)에 쓴다.
<br>

### 3. 제어 유닛 (Control Unit)의 특징
#### Combinational Logic: 멀티 사이클 프로세서가 FSM(Finite State Machine)을 사용하는 것과 달리, 싱글 사이클은 현재 명령어의 Opcode와 Funct 필드만 보고 즉시 모든 제어 신호(ALUOp, RegWrite, MemRead 등)를 생성하는 조합 회로로 구성된다.
