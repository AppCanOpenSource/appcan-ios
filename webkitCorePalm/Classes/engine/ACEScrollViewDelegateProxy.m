/**
 *
 *	@file   	: ACEScrollViewDelegateProxy.m  in AppCanEngine
 *
 *	@author 	: CeriNo
 * 
 *	@date   	: 2016/11/3
 *
 *	@copyright 	: 2016 The AppCan Open Source Project.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */


#import "ACEScrollViewDelegateProxy.h"

@interface ACEScrollViewWeakDelegate : NSObject
@property (nonatomic,weak)id<UIScrollViewDelegate> delegateObject;

@end
@implementation ACEScrollViewWeakDelegate

- (instancetype)initWithDelegate:(id<UIScrollViewDelegate>)delegate{
    self = [super init];
    if (self) {
        _delegateObject = delegate;
    }
    return self;
}

@end

#define DISPATCH_DELEGATE(commands) \
    [self enumerateDelegateResponsingSelector:_cmd withBlock:^(id<UIScrollViewDelegate> _Nullable delegate){commands}]



@interface ACEScrollViewDelegateProxy()
@property (nonatomic,strong)NSMutableArray<ACEScrollViewWeakDelegate *> *delegates;

@end

@implementation ACEScrollViewDelegateProxy

- (NSMutableArray<ACEScrollViewWeakDelegate *> *)delegates{
    if (!_delegates) {
        _delegates = [NSMutableArray array];
    }
    return _delegates;
}

- (void)setMainDelegate:(id<UIScrollViewDelegate>)mainDelegate{
    if (_mainDelegate) {
        [self removeDelegate:_mainDelegate];
    }
    _mainDelegate = mainDelegate;
    [self addDelegate:mainDelegate];
}


- (nullable ACEScrollViewWeakDelegate *)weakDelegateForDelegate:(id<UIScrollViewDelegate>)delegate{
    for(ACEScrollViewWeakDelegate *weakDelegate in self.delegates){
        if(weakDelegate.delegateObject == delegate){
            return weakDelegate;
        }
    }
    return nil;
}

- (void)addDelegate:(id<UIScrollViewDelegate>)delegate{
    if([self weakDelegateForDelegate:delegate]){
        return;
    }
    ACEScrollViewWeakDelegate *weakDelegate = [[ACEScrollViewWeakDelegate alloc]initWithDelegate:delegate];
    [self.delegates addObject:weakDelegate];
}

- (void)removeDelegate:(id<UIScrollViewDelegate>)delegate{
    ACEScrollViewWeakDelegate *weakDelegate = [self weakDelegateForDelegate:delegate];
    if(weakDelegate){
        [self.delegates removeObject:weakDelegate];
    }
}

- (void)enumerateDelegateResponsingSelector:(SEL)sel withBlock:(void (^)(id<UIScrollViewDelegate> _Nullable delegate))block{
    if (!block){
        return;
    }
    for(ACEScrollViewWeakDelegate *delegate in self.delegates){
        if (delegate.delegateObject && [delegate.delegateObject respondsToSelector:sel]){
            block(delegate.delegateObject);
        }
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    DISPATCH_DELEGATE({
        [delegate scrollViewDidScroll:scrollView];
    });
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    DISPATCH_DELEGATE({
        [delegate scrollViewDidZoom:scrollView];
    });
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    DISPATCH_DELEGATE({
        [delegate scrollViewWillBeginDragging:scrollView];
    });
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    DISPATCH_DELEGATE({
        [delegate scrollViewWillEndDragging:scrollView  withVelocity:velocity targetContentOffset:targetContentOffset];
    });
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    DISPATCH_DELEGATE({
        [delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    });
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    DISPATCH_DELEGATE({
        [delegate scrollViewWillBeginDecelerating:scrollView];
    });
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    DISPATCH_DELEGATE({
        [delegate scrollViewDidEndDecelerating:scrollView];
    });
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    DISPATCH_DELEGATE({
        [delegate scrollViewDidEndDecelerating:scrollView];
    });
}


- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view {
    DISPATCH_DELEGATE({
        [delegate scrollViewWillBeginZooming:scrollView withView:view];
    });
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale{
    DISPATCH_DELEGATE({
        [delegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    });
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    DISPATCH_DELEGATE({
        [delegate scrollViewDidScrollToTop:scrollView];
    });
}



- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    if(self.mainDelegate && [self.mainDelegate respondsToSelector:_cmd]){
        return [self.mainDelegate scrollViewShouldScrollToTop:scrollView];
    }
    return YES;
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if(self.mainDelegate && [self.mainDelegate respondsToSelector:_cmd]){
        return [self.mainDelegate viewForZoomingInScrollView:scrollView];
    }
    return nil;
}


@end
