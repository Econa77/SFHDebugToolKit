# SFHDebugToolKit
- Debug用ToolKitをまとめたもの
- 使用できるツール
    - FLEXサポート
        - FLEXとは（ http://natsuapps.com/note/2014/08/flex-dev-tool.html ）
        - 
# サンプルプロジェクト
```
cd ProjectFolder
pod install
```

- ビルド後にシェイクジェスチャー(シミュレーターの場合 Command + Control + Z )で表示

# インストール方法
```
pod 'SFHDebugToolKit', :git => 'git@github.com:Econa77/SFHDebugToolKit.git', :configurations => ['Debug']
```

# 使用方法
Objective-C
```
#if DEBUG
#import "SFHDebugToolKit.h"
#endif

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#if DEBUG
    [SFHDebugToolKit setupToolKit];
#endif
    return YES;
}
```

Swift
- Add "-D DEBUG" flag in " Swift Compiler - Custom Flags - Other Swift Flags - DEBUG "
```
#if DEBUG
#import "SFHDebugToolKit.h"
#endif
```
```
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    #if DEBUG
        SFHDebugToolKit.setupToolKit()
    #endif
    return true
}
```

