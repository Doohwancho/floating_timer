# A. what

![](images/minimal_timer_demo.gif)

Minimal Floating Timer

1. 단축키 특화
2. write TODO
3. 총 누적시간 / 오늘 누적시간 기록
4. 총 streaks / 최신 streaks 기록


# B. Design Decisions

1. 똑같은 일인데 5분을 할당하면 풀집중해서 하는데 한시간 할당하면 질질 끌면서 하더라.([parkinson's law](https://en.wikipedia.org/wiki/Parkinson%27s_law))
2. 그런데 5~15분 단위로 타이머 설정하는게 몰입을 깨기 때문에, 단축키 사용을 극대화한 타이머가 이를 해결해준다.
3. 매일 1분이라도 했으면 calendar에 녹색으로 표시된다.
4. 전문가가 되려면 1만시간의 deliberate practice가 필요하다. 총 누적시간이 1만 시간에 가까워 질 수록 전문가에 가까워 지는 것이다.
5. calendar를 보면 이번달에 얼마나 시간투자를 했는지 한눈에 파악할 수 있다.
6. calendar에 `current streaks` 과 `max streaks`도 매일 꾸준히 시간투자를 하도록 인센티브를 준다.
7. 만들게 된 계기: 아니 어떻게 [타이머 앱](https://apps.apple.com/us/app/onigiri-minimal-timer/id1639917298?mt=12)이 2만 2천원?


# C. keyboard shortcut

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