# SFHDebugToolKit
- Debug用ToolKitをまとめたもの
- Debugビルドのみ使用可能
- 現在はFLEXのみサポート

# サンプルプロジェクト
```
cd ProjectFolder
pod install
```

- ビルド後にシェイクジェスチャー(シミュレーターの場合 Command + Control + Z )で表示

<img src="https://github.com/Econa77/SFHDebugToolKit/blob/master/Images/screenshot.png" width="320px">

# インストール方法
```
pod 'FLEX', :configurations => ['Debug']
pod 'SFHDebugToolKit', :git => 'git@github.com:Econa77/SFHDebugToolKit.git'
```

# 使用方法
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SFHDebugToolKit setupToolKit];
    return YES;
}
```

# TODO
SwiftプロジェクトでDEBUGフラグが使用できているかチェックする
