import UIKit
import CoreGraphics.CGGeometry

final class ALInstaImageZoom: UIImageView {
    
    private var panGesture = UIPanGestureRecognizer()
    private var pinchGesture = UIPinchGestureRecognizer()
    private var initialPoint: CGPoint = .zero
    private var overlayView: UIView?
    
    
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
        initialPoint = center
    }
    
    
    private func resetZooming() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.transform = .identity
            self.center = self.initialPoint
        })
        hideOverlayView()
    }
    
    private func hideOverlayView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.overlayView?.alpha = 0
        }, completion: { (done) in
            self.overlayView?.removeFromSuperview()
            self.overlayView = nil
        })
    }
    
    private func updateOverlayView(scale: CGFloat) {
        
        if scale > 1 && overlayView == nil {
            
            overlayView = UIView(frame: UIScreen.main.bounds)
            overlayView?.alpha = 0
            overlayView?.backgroundColor = .black
            overlayView?.isUserInteractionEnabled = false
            
            if let topView = UIApplication.shared.keyWindow?.rootViewController?.view {
                topView.addSubview(overlayView!)
                topView.sendSubviewToBack(overlayView!)
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
        UIView.animate(withDuration: 0.1) {
            self.overlayView?.alpha = overlayAlpha
        }
    }
    
    @IBAction private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
            case .began, .changed:
                
                    let pinchCenter = CGPoint(x: gesture.location(in: self).x - self.bounds.midX,
                                              y: gesture.location(in: self).y - self.bounds.midY)
                    debugPrint("center: \(pinchCenter)")
                    let transform = self.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                        .scaledBy(x: gesture.scale, y: gesture.scale)
                        .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
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
        switch gesture.state {
            case .began, .changed:
            
                let translation =  gesture.translation(in: self)
                self.center = CGPoint(x: self.center.x + translation.x, y: self.center.y + translation.y)
                gesture.setTranslation(.zero, in: self)
            
            default:
                resetZooming()
        }
    }
    
}

extension ALInstaImageZoom: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
