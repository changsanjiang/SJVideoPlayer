# SJLabel

### 可匹配点击的Label:
<img src="https://github.com/changsanjiang/SJLabel/blob/master/Demo/SJLabel/ex2.gif" />

<img src="https://github.com/changsanjiang/SJAttributesFactory/blob/master/Demo/SJAttributesFactory/action.gif" />

<img src="https://github.com/changsanjiang/SJLabel/blob/master/Demo/SJLabel/ex1.png" />

### Use

```ruby
pod 'SJLabel'
```

### Sample
```Objective-C

_attrStr = [SJAttributesFactory producingWithTask:^(SJAttributeWorker * _Nonnull worker) {
            worker.insertText(@"我被班主任杨老师叫到办公室，当时上课铃刚响，杨老师过来找我，我挺奇怪的，什么事啊，可以连课都不上？", 0);
            worker.font([UIFont boldSystemFontOfSize:22]);
            worker.lineSpacing(8);
            
            worker.regexp(@"我", ^(SJAttributeWorker * _Nonnull regexp) {
                regexp.nextFontColor([UIColor yellowColor]);
                regexp.nextUnderline(NSUnderlineStyleSingle, [UIColor yellowColor]);

                // action 1
                regexp.nextAction(^(NSRange range, NSAttributedString * _Nonnull matched) {
                    NSLog(@"`%@` clicked", matched.string);
                });
            });
            
            __weak typeof(self) _self = self;
            worker.regexp(@"杨老师", ^(SJAttributeWorker * _Nonnull regexp) {
                regexp.nextFontColor([UIColor redColor]);
                
                // action 2
                regexp.next(SJActionAttributeName, ^(NSRange range, NSAttributedString *str) {
                    NSLog(@"`%@` clicked", str.string);
                    
                    __strong typeof(_self) self = _self;
                    if ( !self ) return;
                    UIViewController *vc = [UIViewController new];
                    vc.title = str.string;
                    vc.view.backgroundColor = [UIColor greenColor];
                    [self.navigationController pushViewController:vc animated:YES];
                });
            });
        }];
```


