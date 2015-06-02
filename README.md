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

# インストール方法
```
pod 'FLEX', :configurations => ['Debug']
pod 'SFHDebugToolKit', :git => 'git@github.com:Econa77/SFHDebugToolKit.git'
```

# 使用方法
Objective-C
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SFHDebugToolKit setupToolKit];
    return YES;
}
```

Swift
``` BridgeHeader
#import "SFHDebugToolKit.h"
```
```
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        SFHDebugToolKit.setupToolKit()
        return true
    }
```

