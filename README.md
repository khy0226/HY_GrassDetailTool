Grass Detail GPU Instancing Renderer
=======
잔디나 돌맹이 나뭇가지와 같은 디테일을 직접 심어주거나
 하이라키나 터레인에 심어진 디테일을 외부 데이터 파일에 저장하고 
GPU 인스턴싱으로 렌더링 해주는 툴입니다.  
터레인을 사용을 안하거나 지형과 오브젝트 사이에 잔디를 자연스럽게
심어주기 위한 용도로 만들게 되었습니다.  

##### Unity 2022.3.37f1 (URP) 로 제작하였습니다.
    
##### 기능
* 프리팹 기반의 오브젝트를 브러쉬 툴로 이용해서 지형이나 오브젝트에 심어줍니다.
* 다른 툴을 이용해서 하이라키에 심었을경우 하이라키에 심어진 오브젝트들을 데이터에 저장해줍니다.
* 터레인 디테일에 심은 잔디나 디테일을 데이터로 저장할수 있습니다.
(터레인과 완전히 일치하지는 않습니다.)
* 인스펙터에서 잔디를 보여줄수 있는 최대 거리나 LOD, 그림자 사용여부를 조절할수 있습니다.   
* GPU Instancing을 사용하는 모든 쉐이더에서 사용 가능합니다.
* 하이라키에 심는방식과 비교하면 용량이 크게 줄어듭니다.
* 모바일 환경에 최적화 되어있습니다.
------

##### 수정사항
5월 29일  
* 터레인에서 베이크 할때 속도 증가
* 존 분할 통합 속도 증가
* Draw Mesh Instanced Indirect 추가



------
![easyme](/img/001.png)  
![easyme](/img/002.png)  
![easyme](/img/003.png)  
![easyme](/img/in06.png)  

------
사용방법
======
### Grass Detail Tool
메뉴에서 HY -> Grass Detail Tool 로 실행해줍니다.  
![easyme](/img/004.png) 
#### 공통
Grass Date List : ScriptableObject로 만들어진 데이터를 드래그로 넣을수 있습니다.
  
새 데이터 생성 : ScriptableObject 데이터를 새로 생성합니다.

데이터 불러오기 : ScriptableObject 데이터를 불러옵니다.

데이터 초기화 : 데이터를 초기화 합니다.
  
------
#### Painting
##### 등록된 프리팹
드래그앤 드롭으로 프리팹을 등록합니다.  
![easyme](/img/01.gif) 

대상이 되는 지형의 레이어를 선택하고 브러쉬 활성화 버튼을 눌러줍니다.  
![easyme](/img/02.gif)   
레이어가 일치하면 초록색 원이 보이고 클릭하면 디테일을 심을수 있게됩니다.  
![easyme](/img/03.gif)  
지형뿐만 아니라 오브젝트도 레이어가 일치한다면 바위와 같은 오브젝트에 심을수 있습니다.
  
Brush Size : 브러쉬의 크기를 조절합니다. 기본 사이즈는 1~30까지 조절할수 있고 Max Brush Size를 펼치면 최대 사이즈를 더 크게 조절할수 있습니다.
  
Prefab Distance : 드래그 하면서 심을때 간격을 조절합니다.

Prefab Density : 한번에 심어지는 갯수를 조절합니다.  
![easyme](/img/04.gif)   

Offset : 심어지는 위치를 변경합니다. Random을 체크하면 지정된 범위 안에서 랜덤한 위치로 심어집니다.

Rotation : 방향을 변경합니다. Random을 체크하고 Y축의 Min Rotation을 0으로 Max Rotation을 360으로 입력하면 랜덤한 방향으로 심어줍니다.  
![easyme](/img/06.gif)  

Rotate To Slope : 지형이나 오브젝트의 경사에 자동으로 맞춰줍니다. 기본설정은 활성화 되어있습니다.  
<p float="left">
  <img src="/img/07.gif" width="45%" />
  <img src="/img/08.gif" width="45%" />
</p>

위 이미지 처럼 한쪽은 묻히고 한쪽은 떠보이게 심어지는것을 방지합니다.  

Slope Angle : 각도에 따라서 심어지는 디테일을 조절할수 있습니다.  
![easyme](/img/09.gif)  

Prefab Scale : 디테일의 크기를 조절합니다. Min Scale과 Max Scale을 조절하면 정해진 사이즈만큼 랜덤하게 심어집니다. Multi로 변경할경우 X,Y,Z의 사이즈를 각각 조절할수 있습니다.  
![easyme](/img/10.gif)  

Overlap Prevention : 디테일이 서로 겹치지 않도록 조절합니다.
  
<p float="left">
  <img src="/img/11.gif" width="45%" />
  <img src="/img/12.gif" width="45%" />
</p>

<p>
Scale를 2에 가까울 경우 왼쪽의 이미지처럼 간격이 넓어지고,  
0에 가까울수록 간격이 좁아집니다.
</p>

-----
#### Bake
##### Hierarchy
하이라키에 있는 잔디 디테일 오브젝트를 데이터에 저장할수 있습니다. 
![easyme](/img/005.png)  
Hierarchy를 누르면 위 이미지 처럼 보일것입니다.  

![easyme](/img/16.gif)  
하이라키에 있는 오브젝트를 드래그 해서 등록하고 잔디 데이터로 변환 버튼을 누르면 데이터에 저장이 됩니다.

데이터를 누르면 등록이 되었는지 확인할 수 있습니다.  
![easyme](/img/006.png)  

##### Terrain
터레인으로 심었을경우 터레인과 비슷하게 디테일을 저장합니다. 텍스처기반으로 심어진 잔디와 오브젝트 기반의 디테일 모두 저장이 가능합니다.  
![easyme](/img/007.png)  
Terrain을 누르면 위 이미지 처럼 보일것입니다.  

![easyme](/img/18.gif)  
터레인을 드래그 해서 등록할수 있습니다.

Save Path : 텍스처 기반의 잔디의 프리팹, 매트리얼을 저장할 위치를 지정합니다.

Cross Mesh : 텍스처 기반의 잔디를 저장할때 활성화 했을경우엔 +형태의 메쉬로, 비활성화 했을때는 한장의 플랜으로 저장됩니다.  
![easyme](/img/008.png)  

![easyme](/img/013.png)  
텍스처 기반의 경우는 인스턴스가 너무 많아지기 때문에 아무리 GPU 인스턴싱이라도 속도에 영향이 있기때문에 가능하면 오른쪽처럼 묶어두는것을 추천합니다.
또한 텍스처 기반의 경우 기본 릿 쉐이더 기반으로 설정되어 있기 때문에 사용하던 쉐이더가 있다면 추가적인 작업이 필요합니다.  

Rotate To Slope : 터레인의 경사에 맞춰서 방향을 자동으로 맞춰줍니다.  
![easyme](/img/002.png)  

Y Offset : 디테일이 심어지는 깊이를 조절합니다.  
![easyme](/img/009.png)  

Overlap Prevention : 디테일이 서로 겹치지 않도록 조절합니다.

-----
## Grass Detail Renderer  
### Draw Mesh Instanced
잔디 렌더링을 하기 위해서 하이라키에서 Create Empty를 생성합니다.  
![easyme](/img/010.png)  
 Add Component를 눌러서 HY_GrassDetailRenderer를 추가합니다.  

![easyme](/img/011.png)  
컴포넌트를 추가하고 Grass Date List에 생성한 데이터를 넣으면 ScriptableObject 데이터와 같은 인스펙터 화면이 나옵니다.

#### 지도 및 존 설정
데이터 내에서 존을 분할하지 않으면 모든 잔디 디테일 데이터를 렌더링 하려고 하기 때문에 적당한 크기로 분리를 해야 렌더링에 사용될 CPU사용량이 줄어듭니다.

전체 맵 크기 : 씬에서 설정한 맵 크기만큼 입력합니다.

X 분할 수 및 Y 분할 수 : 전체 맵 크기에 맞춰서 존을 분리해 줍니다. X8 Y8로 했을경우 64등분이 됩니다.  
![easyme](/img/012.png)  
프로 파일러에서 비교을 해보면 통합된 존과 X8 Y8로 64등분된 존과 비교해보면 CPU사용량에서 큰 차이가 있습니다.

#### 공통 잔디 설정
Max Cull Distance : 잔디 디테일을 보여주는 최대 거리를 조절합니다.  
![easyme](/img/13.gif)  

Use Global LOD : Project Settings의 Quality에서 LOD Bias와 연계합니다.

#### 프리팹 설정
Prefab : 잔디를 심거나 베이크로 저장했을때 자동으로 등록됩니다.
만약 터레인 기반으로 등록되었다면 LOD를 사용불가능했기 때문에 LOD를 등록하기 위해서 다른 프리팹으로 교체하는 방식으로 사용 가능합니다.  
![easyme](/img/19.gif)  
프리팹 교체를 하게되면 자동으로 교체될 프리팹의 설정에 맞춰서 자동으로 설정해줍니다.

그림자 사용 : 그림자 활성화 여부를 결정합니다.

Transition Distance : LOD가 바뀌는 거리를 조절합니다. 프리팹에 LOD Group의 설정에 맞춰서 자동으로 조절됩니다.

#### 등록된 존
이 데이터에 등록된 존과 각 존별로 할당되어 있는 잔디갯수를 보여줍니다.

### Draw Mesh Instanced Indirect
![easyme](/img/in02.png)  
![easyme](/img/in03.png)  
![easyme](/img/in07.png)  

#### Draw Mesh Instanced와 차이점
Draw Mesh Instanced는 렌더링은 GPU에서 하지만 LOD, 컬링, 최대거리와 같은 관리는 CPU를 사용하기때문에 잔디를 너무 많이 심게되면 CPU 사용량이 급격하게 늘어납니다.  
Draw Mesh Instanced Indirect는 모든것을 GPU에서 관리하기 때문에 무수히 많은 잔디를 렌더링 하게되면 더욱 빠른 속도로 렌더링 하게 됩니다.  

#### 사용방법
![easyme](/img/in01.png)  
사용 방법은 Draw Mesh Instanced를 Draw Mesh Instanced Indirect로 바꿔 주시면 됩니다.  
주의사항으로는 대부분의 쉐이더는 자동으로 변경해주지만 쉐이더그래프의 경우는 직접 변경해주셔야 합니다.

![easyme](/img/in08.png)  
서브그래프 HY_DrawMeshInstancedIndirect를 Vertex Position에 연결하면 됩니다.  
가능하면 쉐이더그래프를 복사하고 이름 뒤에 (GPUMode)를 붙여주는것을 추천합니다.
 

-----

#### Reference 
<https://gist.github.com/ArieLeo/d7e6bc5485caa9ba99cd3a59d0f53404>  
<https://github.com/ColinLeung-NiloCat/UnityURP-MobileDrawMeshInstancedIndirectExample>
<https://assetstore.unity.com/packages/tools/utilities/gpu-instancer-117566>
