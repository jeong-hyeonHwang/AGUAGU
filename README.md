# AGUAGU
![AGUAGU_2900](https://user-images.githubusercontent.com/96641477/199755300-46e36e01-4176-4d07-aa01-380fac68938e.png)
---
### Available On App Store: [Link](https://apps.apple.com/us/app/aguagu/id1642786388)

> "아구아구가 노란색 열매를 아구아구!"

## Concept Character

|AGUAGU|Description|
|:---:|:---:
|<img width="200" alt="ConceptCharacter_AGUAGU_@JeonghyeonHwang" src="https://user-images.githubusercontent.com/96641477/188483509-fbbc8aea-8c33-450e-89a6-efb0ba8404ed.png">|이 공룡의 이름은 **아구아구**입니다.<br/>아구아구는 오늘도 맛있는 열매를 찾아 떠납니다.|
|**노란 열매**|**Description**|
|<img width="200" alt="ConceptCharacter_YellowFruit_@JeonghyeonHwang" src="https://user-images.githubusercontent.com/96641477/188492150-de680294-d0d6-4dad-b7c5-1dd26cc0a6e3.png">|아구아구는 이 **노란색 열매**를 가장 좋아합니다.<br/> 이 열매라면 아무리 배가 불러도 많이 먹을 수 있어요!|

<br/>아구아구가 노란색 열매를 먹으면?<br/>**아구아구아구아구**...

## 🎡 How to Play
|Keynote|Description|
|:---:|:---:|
|<img width="400" alt="NC2_Presentation 005_@JeonghyeonHwang" src="https://user-images.githubusercontent.com/96641477/188481548-f8b304ac-6297-498c-93ef-bf5a3782c891.png">|**노란색 열매를 챱챱!**|
|<img width="400" alt="NC2_Presentation 006_@JeonghyeonHwang" src="https://user-images.githubusercontent.com/96641477/188491292-7fb64cea-da98-4f0e-aba6-3d96acc4ae77.png">|노란색 열매을 먹으면 1점이 올라갑니다.</br>열매가 사라지기 전까지 먹지 못한다면 게임은 종료됩니다.|
|<img width="400" alt="NC2_Presentation 007_@JeonghyeonHwang" src="https://user-images.githubusercontent.com/96641477/188491298-8a1200f1-b1bf-4614-a8e9-ca54a78c95ad.png">|이전 기록을 갱신했다면 최고 점수로 User Default를 통해 기기에 저장됩니다.|
|<img width="400" alt="NC2_Presentation 008_@JeonghyeonHwang" src="https://user-images.githubusercontent.com/96641477/188491300-c1295a37-1c9b-4501-b022-715d15fdf7d1.png">|게임을 재시작하고 싶은 경우 손을 챱챱!|


## App Demonstration Video
|Game Start & Play|HighScore|Game Restart|
|:---:|:---:|:---:|
|![](https://user-images.githubusercontent.com/96641477/188490798-3882c941-5b53-447b-bf2e-3e181796bcb4.mp4)|![](https://user-images.githubusercontent.com/96641477/188490780-0fbd88a9-c972-4df3-911b-950530be3d35.mov)|![](https://user-images.githubusercontent.com/96641477/188490823-b8857e42-4f79-44a4-99ca-2437c5f7029c.mp4)|

## 🛠 Tech Skill
|Tech|Description|
|:---:|:---|
|**AVFoundation**|사운드 효과 추가 및 영상 처리를 위해 사용|
|**Combine**|영상 처리 시 들고오는 프레임 단위로 들고오는 이미지로부터 '손'을 감지하기 위해 사용|
|**CoreGraphics**|게임의 메인 캐릭터 및 열매를 그리기 위해 사용|
|**UIKit**|기본적인 게임 로직 작성을 위해 사용|
|**Vision**|사용자의 손 감지를 위해 사용|

## 📽 Other Skill
|Skill|Description|
|:---:|:---|
|**Concept Design**|손을 사용하여 '먹는다'는 이미지의 표현을 위해 공룡을 메인 캐릭터로 직접 제작|
|**Design**|원색 계열의 Polygon을 사용하여 사용자의 시선이 분산되지 않도록 절제된 디자인을 반영하며 코드로 제작|
|**Sound**|캐릭터가 화면을 돌아다니는 모습과 열매를 먹는 소리를 표현하기 위해 직접 제작|

## Reference
- [Detecting Hand Poses with Vision](https://developer.apple.com/documentation/vision/detecting_hand_poses_with_vision)
- [Detecting Human Actions in a Live Video Feed](https://developer.apple.com/documentation/createml/detecting_human_actions_in_a_live_video_feed)
