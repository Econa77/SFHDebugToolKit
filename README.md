# SFHDebugToolKit
- Debug用ToolKitをまとめたもの
- 使用できるツール
    - FLEXサポート
        - FLEXとは（http://natsuapps.com/note/2014/08/flex-dev-tool.html）
    - 録画機能
        - 録画ボタンを押して停止する間の画面キャプチャをカメラロールに保存
        - 画面の関係でアクションシートなど、メイン画面にないものは映らない可能性があります

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
#if
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
``` BridgeHeader
#import "SFHDebugToolKit.h"
```
```
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    SFHDebugToolKit.setupToolKit()
    return true
}
```

