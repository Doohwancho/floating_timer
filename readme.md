# A. 소개

## a. 단축키 특화 floating timer
![](images/minimal_timer_demo.gif)

1. Minimal View
	- `feat`: write TODO
	- `feat`: decremental timer(press spacebar, 시간 누적 O)
	- `feat`: incremental timer(press command + s, 시간 누적 X)
	- `feat`: 총 누적시간 / 오늘 누적시간 기록
2. Timer View
3. Calendar View
	- `feat`: 총 streaks / 최신 streaks 기록
	- `feat`: calendar에 해당 날짜에 몇시간 한지 기록
	- `feat`: 이전 달, 다음 달을 h,l 키로 이동


## b. keyboard shortcut

```
- spacebar: start/pause decremental timer
- command + s: start/stop increment timer
- 숫자키: 시간 설정(in minute)
- command + 1: minimal timer mode
- command + 2: transparent timer mode
- command + 3: calendar mode
- i: insert mode(set goal on minimal_timer)
- esc, enter: exit insert mode
- h,l to switch months in calendar
```

<!--
# B. Design Decisions

## 1. parkinson's law

[파킨슨의 법칙](https://en.wikipedia.org/wiki/Parkinson%27s_law)에 의하면,

> "Work expands to fill the available time"

똑같은 일을 15분 할당하면 15분만에 풀집중해서 끝내는데,\
**2시간 할당하면 질질 끌다가 2시간 맞춰서 끝낸다.**

타이머로 각 일마다 내 능력에 맞게 적정 시간을 할당할 수 있다.


## 2. 단축키로 타이머 세팅 귀찮음 문제 해결
15분마다 타이머 시간/할일 재설정하는게 매우 귀찮다는 단점이 있다.

단축키를 쓰면 타이머 세팅에 신경을 덜 쓰게 되어 몰입을 깨는걸 줄일 수 있다.


## 3. 얼마나 시간이 걸릴지 예측하는 재미
각 TODO마다 몇분 걸릴지 예측해서 맞추는 게임


## 4. TODO에 할일 적고 하나씩 지워가는 재미
그날 하루 해야할일 순서대로 다 적고, 그걸 하나씩 지울 때마다 도파민 느낌

그날 목표한걸 다 끝내면, 큰 성취감을 느낀다.


## 5. john carmack's plan
https://github.com/ESWAT/john-carmack-plan-archive/tree/master/by_day


# C. How

1. goal에 역순으로 roadmap을 step by step으로 쪼개되, 쪼개는 단위는 1 commit 단위
2. 첫 TODO는 하기싫은데 중요한걸로 채운다. (하고싶은건 의지력이 떨어져도 어짜피 함)
3. 각 TODO당 소요시간을 적는다.
4. TODO 형식은 `1. TODO : 걸리는시간`
5. 모든 TODO가 clear되지 않으면 잠을 자지 않는다. (하루만 잠을 적게 자면 수면시간 확보하려고 TODO list를 현실적인 수준으로 조절하고, 시간안에 집중해서 끝내려고 함)
6. 오해) 이건 일처리할 때 쓰는 툴이지 공부할 떄 쓰는 툴은 아니다. 공부는 자유롭게 탐구하는 식으로 해야한다.

-->
