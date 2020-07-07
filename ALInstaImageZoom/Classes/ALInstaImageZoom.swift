import UIKit
import CoreGraphics.CGGeometry

final public class ALInstaImageZoom: UIImageView {
    
    private var panGesture = UIPanGestureRecognizer()
    private var pinchGesture = UIPinchGestureRecognizer()
    
    private var overlayView: UIView?
    
    private var initialSuperView: UIView?
    
    private var parentScrollViews: [(scrollView: UIScrollView, enable: Bool)]?
    
    private var copyImageView: UIImageView?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        commonInit()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        panGesture.delegate = self
        panGesture.addTarget(self, action: #selector(handlePanGesture(_:)))
        panGesture.minimumNumberOfTouches = 2
        panGesture.maximumNumberOfTouches = 2
        addGestureRecognizer(panGesture)
        
        pinchGesture.delegate = self
        pinchGesture.addTarget(self, action: #selector(handlePinchGesture(_:)))
        addGestureRecognizer(pinchGesture)
        
        isUserInteractionEnabled = true
    }
    
    
    private func resetZooming() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.transform = .identity
            self.copyImageView?.transform = .identity
        })
        hideOverlayView()
        unlockParentScrollView()
    }
    
    private func hideOverlayView() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.overlayView?.alpha = 0
            self.alpha = 1
            
        }, completion: { (done) in
            self.overlayView?.removeFromSuperview()
            self.overlayView = nil
            
            self.copyImageView?.removeFromSuperview()
            self.copyImageView = nil
        })
    }
    
    private func updateOverlayView(scale: CGFloat) {
        
        if scale > 1 && overlayView == nil {
            
            overlayView = UIView(frame: UIScreen.main.bounds)
            overlayView?.alpha = 0
            overlayView?.backgroundColor = .black
            overlayView?.isUserInteractionEnabled = false
            
            initialSuperView = superview
            
            lockParentScrollView()
            
           
            if let topVC = UIApplication.getTopViewController(base: self.parentViewController) {
                
                let realFrame = topVC.view.convert(frame, from: superview)
                copyImageView = UIImageView(frame: realFrame)
                copyImageView?.image = image
                copyImageView?.contentMode = contentMode
                copyImageView?.isUserInteractionEnabled = false
                alpha = 0
              
                topVC.view.addSubview(overlayView!)
                topVC.view.addSubview(copyImageView!)
            }
        }
        
        
        var overlayAlpha: CGFloat = 0
        
        if scale <= 1 {
            overlayAlpha = 0
        } else if scale > 1 && scale < 1.5 {
            overlayAlpha = (scale - 1) * 2
        } else {
            overlayAlpha = 1
        }
        self.overlayView?.alpha = overlayAlpha
    }
    
    private func lockParentScrollView() {
        
        var tmpView: UIView? = self
        
        while tmpView?.superview != nil {
            tmpView = tmpView?.superview
            if tmpView?.isKind(of: UIScrollView.self) ?? false , let scrollView = tmpView as? UIScrollView {
                parentScrollViews?.append((scrollView, scrollView.isUserInteractionEnabled ?? false))
                scrollView.isScrollEnabled = false
            }
        }
    }
    
    private func unlockParentScrollView() {
        parentScrollViews?.forEach({ (scrollView, enable) in
            scrollView.isScrollEnabled = enable
        })
    }
    
    
    
    @IBAction private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
            case .began, .changed:
                
                    let pinchCenter = CGPoint(x: gesture.location(in: superview).x - self.bounds.midX,
                                              y: gesture.location(in: superview).y - self.bounds.midY)
                    
                    let transform = self.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                        .scaledBy(x: gesture.scale, y: gesture.scale)
                        .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                    
                    debugPrint("ALInsta: trans\(transform)")
                    self.copyImageView?.transform = transform
                    self.transform = transform
                    gesture.scale = 1
                    
                    updateOverlayView(scale: transform.a)
                    
                    if transform.a <= 1 {
                        resetZooming()
                        return
                    }
                break;
            default:
                resetZooming()
        }
    }
    
    
    @IBAction private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        // TODO: There is a problem with pan gesture. Needs work perfect with pinch but there is some glitch.
        // FIXME: Need to fix.
        
//        switch gesture.state {
//            case .began, .changed:
//
//                let topView = overlayView ?? self
//                let translation =  gesture.translation(in: topView)
//                let newPoint = CGPoint(x: self.center.x + translation.x, y: self.center.y + translation.y)
//                copyImageView?.center = newPoint
//                self.center = newPoint
//                gesture.setTranslation(.zero, in: topView)
//
//            default:
//                resetZooming()
//        }
    }
    
}

extension ALInstaImageZoom: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
