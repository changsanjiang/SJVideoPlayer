# SJAttributesFactory

```ruby
  pod 'SJAttributesFactory'
```
另外关于富文本的属性介绍, 请查看:
http://www.jianshu.com/p/ebbcfc24f9cb
___
### 上下图文效果:
![上下图文.jpg](http://upload-images.jianshu.io/upload_images/2318691-e92f48d24e29ae61.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

before:
```Objective-C
   // 文本字典
    NSDictionary *titleDict = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize],
                                NSForegroundColorAttributeName: titleColor};
    NSDictionary *spacingDict = @{NSFontAttributeName: [UIFont systemFontOfSize:spacing]};

    // 图片文本
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, 0, imageW, imageH);
    NSAttributedString *imageText = [NSAttributedString attributedStringWithAttachment:attachment];

    // 换行文本
    NSAttributedString *lineText = [[NSAttributedString alloc] initWithString:@"\n\n" attributes:spacingDict];

    // 按钮文字
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:title attributes:titleDict];

    // 合并文字
    NSMutableAttributedString *attM = [[NSMutableAttributedString alloc] initWithAttributedString:imageText];
    [attM appendAttributedString:lineText];
    [attM appendAttributedString:text];
```
now:
```Objective-C
[SJAttributesFactory alteringStr:@"9999" task:^(SJAttributesFactory * _Nonnull worker) {
        worker
        .insertText(@"\n", 0)
        .insertImage([UIImage imageNamed:@"sample2"], CGPointZero, CGSizeMake(50, 50), 0)
        .lineSpacing(8) // 加点行间隔
        .alignment(NSTextAlignmentCenter)
        .font([UIFont boldSystemFontOfSize:14])
        .fontColor([UIColor whiteColor]);
    }];
```
___

### 左缩进 + 右缩进
![左缩进 + 右缩进.jpeg](http://upload-images.jianshu.io/upload_images/2318691-9823aa20d6789463.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

before:
```Objective-C
    NSString *str = @"故事:可以解释为旧事、旧业、先例、典故等涵义,同时,也是文学体裁的一种,侧重于事情过程的描述,强调情节跌宕起伏,从而阐发道理或者价值观。";

    NSMutableAttributedString *attrM = [[NSMutableAttributedString alloc] initWithString:str];
    [attrM addAttribute:NSFontAttributeName
                  value:[UIFont boldSystemFontOfSize:14]
                  range:NSMakeRange(0, 3)];
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.firstLineHeadIndent = 8;
    style.headIndent = [[attrM attributedSubstringFromRange:NSMakeRange(0, 3)]
                                       boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
     context:nil].size.width + style.firstLineHeadIndent;

    style.tailIndent = -8;
    [attrM addAttribute:NSParagraphStyleAttributeName
                  value:style
                  range:NSMakeRange(0, str.length)];
```
now:
```Objective-C
    [SJAttributesFactory alteringStr:@"故事:可以解释为旧事、旧业、先例、典故等涵义,同时,也是文学体裁的一种,侧重于事情过程的描述,强调情节跌宕起伏,从而阐发道理或者价值观。" task:^(SJAttributesFactory * _Nonnull worker) {
        worker.nextFont([UIFont boldSystemFontOfSize:14]).range(NSMakeRange(0, 3));
        CGFloat startW = worker.width(NSMakeRange(0, 3));

        worker
        .firstLineHeadIndent(8)
        .headIndent(startW + 8)
        .tailIndent(-8);       
    }];
```
___
### 下划线 + 删除线
![下划线 + 删除线.jpg](http://upload-images.jianshu.io/upload_images/2318691-f9babe81194300fa.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

before:
```Objective-C
    NSString *price = @"$ 999";
    NSMutableAttributedString *attrM = [[NSMutableAttributedString alloc] initWithString:price];
    NSRange range = NSMakeRange(0, price.length);
    [attrM addAttribute:NSFontAttributeName
                  value:[UIFont systemFontOfSize:40]
                  range:range];
    [attrM addAttribute:NSUnderlineStyleAttributeName
                  value:@(NSUnderlineByWord | NSUnderlinePatternSolid | NSUnderlineStyleDouble)
                  range:range];
    [attrM addAttribute:NSUnderlineColorAttributeName
                  value:[UIColor yellowColor]
                  range:range];
    [attrM addAttribute:NSStrikethroughStyleAttributeName
                  value:@(NSUnderlineByWord | NSUnderlinePatternSolid | NSUnderlineStyleDouble)
                  range:range];
    [attrM addAttribute:NSStrikethroughColorAttributeName
                  value:[UIColor redColor]
                  range:range];
```
now:
```Objective-C
    [SJAttributesFactory alteringStr:@"$ 999" task:^(SJAttributesFactory * _Nonnull worker) {
        worker.font([UIFont systemFontOfSize:40]);
        worker.underline(NSUnderlineByWord | NSUnderlinePatternSolid | NSUnderlineStyleDouble, [UIColor yellowColor]).strikethrough(NSUnderlineByWord | NSUnderlinePatternSolid | NSUnderlineStyleDouble, [UIColor redColor]);
    }];
```
___

## Other
![ex.gif](http://upload-images.jianshu.io/upload_images/2318691-9b547ad5a35710f6.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
