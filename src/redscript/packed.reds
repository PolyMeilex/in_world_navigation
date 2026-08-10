enum InWorldNavigationMode {
  Always = 0,
  Driving = 1,
  Walking = 2
}

public native class InWorldNavigation extends IScriptable {
  public static native func GetInstance() -> ref<InWorldNavigation>;

  public let mmcc: ref<MinimapContainerController>;
  public let player: ref<GameObject>;
  
  @runtimeProperty("ModSettings.mod", "In-World Navigation")
  @runtimeProperty("ModSettings.displayName", "Enabled")
  let enabled: Bool = true;

  @runtimeProperty("ModSettings.mod", "In-World Navigation")
  @runtimeProperty("ModSettings.displayName", "Display mode")
  @runtimeProperty("ModSettings.displayValues", "\"Always\", \"When Driving\", \"When Walking\"")
  @runtimeProperty("ModSettings.dependency", "enabled")
  let mode: InWorldNavigationMode = InWorldNavigationMode.Driving;

  @runtimeProperty("ModSettings.mod", "In-World Navigation")
  @runtimeProperty("ModSettings.displayName", "Arrow spacing")
  @runtimeProperty("ModSettings.description", "In-game units between arrows")
  @runtimeProperty("ModSettings.step", "0.5")
  @runtimeProperty("ModSettings.min", "0.5")
  @runtimeProperty("ModSettings.max", "20.0")
  @runtimeProperty("ModSettings.dependency", "enabled")
  let spacing: Float = 5.0;

  @runtimeProperty("ModSettings.mod", "In-World Navigation")
  @runtimeProperty("ModSettings.displayName", "Max number of arrows")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "10")
  @runtimeProperty("ModSettings.max", "2000")
  @runtimeProperty("ModSettings.dependency", "enabled")
  let maxPoints: Int32 = 200;

  @runtimeProperty("ModSettings.mod", "In-World Navigation")
  @runtimeProperty("ModSettings.displayName", "Distance within arrows will fade")
  @runtimeProperty("ModSettings.description", "Measures from player")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "0.0")
  @runtimeProperty("ModSettings.max", "100.0")
  @runtimeProperty("ModSettings.dependency", "enabled")
  let distanceToFade: Float = 25.0;

  let navPathFXs: array<array<ref<FxInstance>>>;
  let navPathTransforms: array<array<Transform>>;

  let navPathYellowResource: FxResource;
  let navPathBlueResource: FxResource;
  let navPathWhiteResource: FxResource;
  let navPathTealResource: FxResource;
  let navPathCyanResource: FxResource;
  let navPathFastTravelMetroResource: FxResource;

  let distanceToAnimate: Float;

  public func Setup(player: ref<GameObject>) -> Void {
    this.player = player;
    this.distanceToAnimate = 50.0;
    
    this.navPathYellowResource = Cast<FxResource>(r"user\\jackhumbert\\effects\\world_navigation_yellow.effect");
    this.navPathBlueResource = Cast<FxResource>(r"user\\jackhumbert\\effects\\world_navigation_blue.effect");
    this.navPathWhiteResource = Cast<FxResource>(r"user\\jackhumbert\\effects\\world_navigation_white.effect");
    this.navPathTealResource = Cast<FxResource>(r"user\\jackhumbert\\effects\\world_navigation_teal.effect");
    this.navPathCyanResource = Cast<FxResource>(r"user\\jackhumbert\\effects\\world_navigation_cyan.effect");
    this.navPathFastTravelMetroResource = Cast<FxResource>(r"user\\jackhumbert\\effects\\fast_travel_metro.effect");

    let questFx: array<ref<FxInstance>>;
    let poiFx: array<ref<FxInstance>>;
    ArrayPush(this.navPathFXs, questFx);
    ArrayPush(this.navPathFXs, poiFx);

    let questTransforms: array<Transform>;
    let poisTransforms: array<Transform>;
    ArrayPush(this.navPathTransforms, questTransforms);
    ArrayPush(this.navPathTransforms, poisTransforms);
    this.RegisterModSettings();
  }

  @if(ModuleExists("ModSettingsModule"))
  private func RegisterModSettings() {
    ModSettings.RegisterListenerToClass(this);
  }

  @if(!ModuleExists("ModSettingsModule"))
  private func RegisterModSettings() {}

  public func Update(canUpdate: Int32) {
    if IsDefined(this.mmcc) {
      let isMounted = VehicleComponent.IsMountedToVehicle(this.player.GetGame(), this.player);
      if this.enabled && 
        ((isMounted && NotEquals(this.mode, InWorldNavigationMode.Walking)) ||
         (!isMounted && NotEquals(this.mode, InWorldNavigationMode.Driving))
        ) { 

        if ArraySize(this.mmcc.questPoints) > 2 {
          this.UpdateNavPath(0, this.mmcc.questPoints, this.navPathCyanResource, false);
        } else {     
          for fx in this.navPathFXs[0] {
            fx.BreakLoop();
          }
        }

        if ArraySize(this.mmcc.poiPoints) > 2 {
          this.UpdateNavPath(1, this.mmcc.poiPoints, this.navPathTealResource, false);
        } else {
          for fx in this.navPathFXs[1] {
            fx.BreakLoop();
          }
        }
      } else {
        this.Stop();
      }
    }
  }

  public func Stop() {
    for fx in this.navPathFXs[0] {
      fx.BreakLoop();
    }
    for fx in this.navPathFXs[1] {
      fx.BreakLoop();
    }
  }

  let timer: Float;

  private func UpdateNavPath(type: Int32, points: array<Vector4>, resource: FxResource, force: Bool) -> Void {
    let pointDrawnCount: Int32 = 0;
    let dots: array<Transform>;
    let i = ArraySize(points) - 1;
    let lastDrawnPoint: Vector4 = points[i];

    while i > 0 {
      let tweenPointDistance = Vector4.Distance(points[i-1], lastDrawnPoint);
      if i == 1 {
        tweenPointDistance += this.spacing;
      }
      if tweenPointDistance >= this.spacing {
        // let rounded = Cast<Float>(RoundF(tweenPointDistance / this.spacing));
        // let tweenPointSpacing = this.spacing + (tweenPointDistance - rounded * this.spacing) / rounded;
        let lastDrawnPointInLastGroup = lastDrawnPoint;
        let distance = this.spacing;
        while distance <= tweenPointDistance {
          let ratio: Float = distance / tweenPointDistance;
          let position = Vector4.Interpolate(lastDrawnPointInLastGroup, points[i-1], ratio);
          let orientation = Quaternion.BuildFromDirectionVector(lastDrawnPoint - position);
          distance += this.spacing;
          ArrayPush(dots, Transform.Create(position, orientation));
          lastDrawnPoint = position;
        }
      }
      i -= 1;
    }

    i = 0;
    while i < ArraySize(dots) {
      if ArraySize(this.navPathTransforms[type]) <= i {
        ArrayPush(this.navPathTransforms[type], dots[i]);
      } else {
        if Vector4.Distance(this.navPathTransforms[type][i].position, dots[i].position) < this.distanceToAnimate {
          this.navPathTransforms[type][i].position = Vector4.Interpolate(this.navPathTransforms[type][i].position, dots[i].position, 0.1);
          this.navPathTransforms[type][i].orientation = Quaternion.Slerp(this.navPathTransforms[type][i].orientation, dots[i].orientation, 0.1);
        } else {
          this.navPathTransforms[type][i].position = dots[i].position;
          this.navPathTransforms[type][i].orientation = dots[i].orientation;
        }
      }
      i += 1;
    }

    ArrayResize(this.navPathTransforms[type], ArraySize(dots));

    i = ArraySize(dots) - 1;

    while pointDrawnCount < this.maxPoints && i >= 0 {
      let p = this.navPathTransforms[type][i].position;
      let q = this.navPathTransforms[type][i].orientation;
      this.UpdateFxInstance(type, pointDrawnCount, p, q, resource, force);
      pointDrawnCount += 1;
      i -= 1;
    }

    while pointDrawnCount < this.maxPoints && pointDrawnCount < ArraySize(this.navPathFXs[type]) {   
      this.navPathFXs[type][pointDrawnCount].SetBlackboardValue(n"alpha", 0.0);
      this.navPathFXs[type][pointDrawnCount].BreakLoop();
      this.navPathFXs[type][pointDrawnCount].Kill();
      pointDrawnCount += 1;
    }
  }

  private func UpdateFxInstance(type: Int32, i: Int32, p: Vector4, q: Quaternion, resource: FxResource, force: Bool) {
    let wt: WorldTransform;
    WorldTransform.SetPosition(wt, p);
    WorldTransform.SetOrientation(wt, q);
    if i >= ArraySize(this.navPathFXs[type]) {
      ArrayPush(this.navPathFXs[type], GameInstance.GetFxSystem(this.player.GetGame()).SpawnEffect(resource, wt));
    } else { 
      if IsDefined(this.navPathFXs[type][i]) && this.navPathFXs[type][i].IsValid() && !force {
        this.navPathFXs[type][i].UpdateTransform(wt);
      } else {
        if IsDefined(this.navPathFXs[type][i]) {
          this.navPathFXs[type][i].BreakLoop();
          this.navPathFXs[type][i].Kill();
        }
        this.navPathFXs[type][i] = GameInstance.GetFxSystem(this.player.GetGame()).SpawnEffect(resource, wt);
      }
    }
    this.navPathFXs[type][i].SetBlackboardValue(n"alpha", MinF(Vector4.Distance2D(this.player.GetWorldPosition(), p) / this.distanceToFade, 1.0));
  }
}


// in_world_navigation/OperatorHelpers.reds

// FxResource

public static native func Cast(a: ResRef) -> FxResource;


// in_world_navigation/_MinimapContainerController.reds

@wrapMethod(MinimapContainerController)
protected final func InitializePlayer(playerPuppet: ref<GameObject>) -> Void {
  wrappedMethod(playerPuppet);
  let iwn = InWorldNavigation.GetInstance();
  iwn.Setup(playerPuppet);
  iwn.mmcc = this;
}

@addField(MinimapContainerController)
public native let questPoints: array<Vector4>;

@addField(MinimapContainerController)
public native let poiPoints: array<Vector4>;


