# A. what

![](images/2024-05-20-19-41-12.png)

Minimal Floating Timer

만들게 된 계기: 아니 어떻게 타이머 앱이 2만 2천원?

# B. feature

1. timer(decremental, incremental)
2. floating
3. keyboard shortcuts
4. layout: 1. goal / 2. today's accumulated time / 3. total accumulate time


# C. shortcut

```
1. spacebar: start/pause decremental timer
2. command + s: start/pause increment timer
3. 숫자키: 시간 설정(in minute)
4. command + 1: minimal timer mode
5. command + 2: transparent mode
6. i: insert mode(set goal)
7. esc: exit insert mode
```

# D. TODO

1. insert mode에서 capslock 눌렀을 때 부숴진 ascii code 입력되는 문제 해결하기
2. calendar 추가(using library?) and mode에 추가
3. 오늘 시간 추가한게 calendar의 today에 추가되는 기능 추가
4. 앱을 닫을 때 시간 저장 시 date:시간 으로 저장하고, 앱 로드시 calendar에서 파싱
