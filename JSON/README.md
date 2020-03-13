# 소개
JSON 파일을 만들고 읽기 위한 모듈입니다.

```json.exe``` 파일을 빌드하려면 ```Ruby v2.3``` 버전 이상을 설치하고 환경 변수 PATH에 루비가 설치된 경로를 설정하세요.

그 후, 명령 프롬프트를 열고 아래와 같이 입력하면 ```ocra``` 라이브러리가 설치됩니다. 
```ocra```는 단일 실행 파일을 만드는 라이브러리입니다. 단일 실행 파일처럼 보이지만 사실 트릭에 가깝습니다. 모든 파일을 실행 파일 내에 LZMA로 압축이 되어있는데, 실행 시엔 해당 파일들이 임시 폴더 ```AppData/Local/Temp```에 압푹이 풀린 상태로 존재하게 됩니다. 따라서 해제된 파일을 가지고 새로운 프로세스를 만들어주는 것입니다. 프로세스가 종료될 때 임시로 만든 파일을 삭제하는 구조입니다.

```
gem install ocra -v 1.3.6
```

설치가 완료되면 ```build.bat``` 파일을 실행하면 ```bin``` 폴더에 실행 파일이 생성됩니다.

# 사용법

JSON 파일의 작성은 다음과 같이 할 수 있습니다.

```ruby
JSON.to_json({
  :name => "러닝은빛",
  :date => Time.now.to_s,
  :input => Input.constants
}, "settings.json")
```

이렇게 하면 파일은 다음과 같이 만들어집니다.

```json
{
  "name": "러닝은빛",
  "date": "2020-03-13 14:40:05 +0900",
  "input": [
    "LEFT",
    "UP",
    "RIGHT",
    "DOWN",
    "A",
    "B",
    "C",
    "X",
    "Y",
    "Z",
    "L",
    "R",
    "SHIFT",
    "CTRL",
    "ALT",
    "F5",
    "F6",
    "F7",
    "F8",
    "F9",
    "FindWindowW",
    "GetKeyboardState",
    "GetCursorPos",
    "ScreenToClient",
    "GetAsyncKeyState",
    "GetKeyNameTextW",
    "MapVirtualKey",
    "RSGetWheelDelta",
    "RSResetWheelDelta",
    "GetText",
    "MAPVK_VSC_TO_VK_EX",
    "WINDOW_NAME",
    "HANDLE",
    "KEY",
    "DEFEAULT_SYM",
    "SPECIFIC_KEY",
    "STATES",
    "MOUSE_BUTTON"
  ]
}
```

JSON 파일을 읽으려면 다음과 같이 하세요. 반환값은 ```Hash```입니다.

```ruby
JSON.parse("output.json")
```