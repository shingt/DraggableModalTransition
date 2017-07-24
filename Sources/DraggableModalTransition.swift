import UIKit
import UIKit.UIGestureRecognizerSubclass

public class DraggableModalTransition: UIPercentDrivenInteractiveTransition {
    public var transitionDuration: CGFloat = 0.6
    public var velocityThresholdToDismiss: CGFloat = 100.0
    public var boundingMargin: CGFloat = 20
    
    fileprivate var gestureRecognizerProxy: UIPanGestureRecognizer?
    fileprivate weak var modalViewController: UIViewController!
    fileprivate var transitionContext: UIViewControllerContextTransitioning?
    fileprivate var panGestureStartLocationY: CGFloat = 0.0
    fileprivate lazy var backgroundView: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        return view
    }()
    
    enum DraggingState {
        case `default`
        case ready
        case dragging
       
        var draggable: Bool {
            return self != .default
        }
    }
    enum AnimationMode {
        case presentation
        case dismissal
    }
    fileprivate var draggingState: DraggingState = .default
    fileprivate var animationMode: AnimationMode = .presentation
    fileprivate var isSwiping = false
    fileprivate var dismissed = false
    
    public init(with modalViewController: UIViewController) {
        self.modalViewController = modalViewController
        
        super.init()
        
        self.removeGestureRecognizerFromModalViewController()
        let gestureRecognizerProxy = UIPanGestureRecognizer(target:self, action:#selector(handlePanGesture(recognizer:)))
        gestureRecognizerProxy.delegate = self
        self.modalViewController.view.addGestureRecognizer(gestureRecognizerProxy)
        self.gestureRecognizerProxy = gestureRecognizerProxy
    }

    fileprivate func removeGestureRecognizerFromModalViewController() {
        guard let gestureRecognizerProxy = gestureRecognizerProxy else { return }
        guard let gestureRecognizers = modalViewController.view.gestureRecognizers else { return }
        guard gestureRecognizers.contains(gestureRecognizerProxy) else { return }
        
        modalViewController.view.removeGestureRecognizer(gestureRecognizerProxy)
        self.gestureRecognizerProxy = nil
    }
    
    internal func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        isSwiping = true
        
        let location = recognizer.location(in: modalViewController.view.window)
        let velocity = recognizer.velocity(in: modalViewController.view.window)

        switch recognizer.state {
        case .began:
            if draggingState.draggable {
                setupInteractiveTransition(atLocationY: location.y)
            }
        case .changed:
            guard draggingState.draggable else { return }
            guard dismissed else {
                setupInteractiveTransition(atLocationY: location.y)
                return
            }
            guard let fromViewController = transitionContext?.viewController(forKey: .from) else { return }
            
            if fromViewController.view.frame.origin.y <= 0 {
                fromViewController.view.frame.origin.y = 0
                guard velocity.y >= 0 else {
                    draggingState = .ready
                    return
                }
                
                if case .ready = draggingState {
                    panGestureStartLocationY = location.y
                }
            }
            draggingState = .dragging
            let animationRatio: CGFloat = (location.y - panGestureStartLocationY) / modalViewController.view.bounds.height
            update(animationRatio)
        case .ended:
            guard draggingState.draggable else { cancel(); return }
            velocity.y > velocityThresholdToDismiss ? finish() : cancel()
        case .cancelled, .failed:
            cancel()
        default:
            return
        }
    }

    override public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        
        transitionContext.containerView.addSubview(toViewController.view)
        transitionContext.containerView.addSubview(backgroundView)
        transitionContext.containerView.bringSubview(toFront: fromViewController.view)
    }

    override public func update(_ percentComplete: CGFloat) {
        guard let fromViewController = transitionContext?.viewController(forKey: .from) else { return }
        let targetY = max(fromViewController.view.bounds.height * percentComplete, 0)
        let targetRect = CGRect(
            x: 0,
            y: targetY,
            width: fromViewController.view.bounds.width,
            height: fromViewController.view.bounds.height
        )
        fromViewController.view.frame = targetRect
        backgroundView.alpha = 1.0 - percentComplete
    }

    override public func finish() {
        guard let transitionContext = transitionContext else { return }
        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
       
        gestureRecognizerProxy?.isEnabled = false
        let targetRect = CGRect(
            x: 0,
            y: fromViewController.view.bounds.height,
            width: fromViewController.view.bounds.width,
            height: fromViewController.view.bounds.height)
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.1,
            options: UIViewAnimationOptions.curveEaseOut,
            animations: {
                fromViewController.view.frame = targetRect
                self.backgroundView.alpha = 0.0
        }, completion: { _ in
            let didCompleteTransition = !transitionContext.transitionWasCancelled
            transitionContext.completeTransition(didCompleteTransition)
            self.cleanUpTransition()
        })
    }

    override public func cancel() {
        guard let transitionContext = transitionContext else { return }
        transitionContext.cancelInteractiveTransition()
        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        
        gestureRecognizerProxy?.isEnabled = false
        let targetRect = CGRect(
            x: 0,
            y: 0,
            width: fromViewController.view.bounds.width,
            height: fromViewController.view.bounds.height
        )
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.1,
            options: UIViewAnimationOptions.curveEaseOut,
            animations: {
                fromViewController.view.frame = targetRect
                self.backgroundView.alpha = 1.0
        }, completion: { _ in
            transitionContext.completeTransition(false)
            toViewController.view.removeFromSuperview()
            self.cleanUpTransition()
        })
    }

    private func cleanUpTransition() {
        draggingState = .default
        dismissed = false
        gestureRecognizerProxy?.isEnabled = true
        isSwiping = false
    }
    
    private func setupInteractiveTransition(atLocationY: CGFloat) {
        guard let modalViewController = modalViewController else { return }
        
        panGestureStartLocationY = atLocationY
        draggingState = .dragging
        modalViewController.dismiss(animated: true, completion: nil)
        dismissed = true
    }
}

// pragma mark - UIViewControllerAnimatedTransitioning
extension DraggableModalTransition: UIViewControllerAnimatedTransitioning {
    public func animationEnded(_ transitionCompleted: Bool) {
        draggingState = .default
        transitionContext = nil
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(transitionDuration)
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard draggingState != .dragging else { return }

        switch animationMode {
        case .presentation:
            animateTransitionForPresentation(using: transitionContext)
        case .dismissal:
            animateTransitionForDismissal(using: transitionContext)
        }
    }
    
    private func animateTransitionForPresentation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(backgroundView)        
        containerView.addSubview(toViewController.view)

        backgroundView.alpha = 0.0
        let startRect = CGRect(
            x: 0,
            y: containerView.bounds.height,
            width: containerView.bounds.width,
            height: containerView.bounds.height
        )
        toViewController.view.frame = startRect
        let originalHeight = toViewController.view.bounds.height
        let targetRect = CGRect(
            x: 0,
            y: 0,
            width: toViewController.view.bounds.width,
            height: originalHeight + boundingMargin
        )
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.1,
            options: UIViewAnimationOptions.curveEaseOut,
            animations: {
                toViewController.view.frame = targetRect
                self.backgroundView.alpha = 1.0
        }, completion: { _ in
            let didCompleteTransition = !transitionContext.transitionWasCancelled
            transitionContext.completeTransition(didCompleteTransition)
            toViewController.view.bounds.size.height = originalHeight
        })
    }
    
    private func animateTransitionForDismissal(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toViewController.view)
        containerView.addSubview(backgroundView)
        containerView.bringSubview(toFront: fromViewController.view)
        
        backgroundView.alpha = 1.0
        let targetRect = CGRect(
            x: 0,
            y: fromViewController.view.bounds.height,
            width: fromViewController.view.bounds.width,
            height: fromViewController.view.bounds.height
        )
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.1,
            options: UIViewAnimationOptions.curveEaseOut,
            animations: {
                fromViewController.view.frame = targetRect
                self.backgroundView.alpha = 0.0
        }, completion: { _ in
            toViewController.view.layer.transform = CATransform3DIdentity
            let didCompleteTransition = !transitionContext.transitionWasCancelled
            transitionContext.completeTransition(didCompleteTransition)
        })
    }
}

// pragma mark - UIViewControllerTransitioningDelegate
extension DraggableModalTransition: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationMode = .presentation
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationMode = .dismissal
        return self
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }

    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard isSwiping else { 
            return nil
        }
        return self
    }
}

// pragma mark - UIGestureRecognizerDelegate
extension DraggableModalTransition: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

public protocol ModalViewControllerDelegate: class {
    func modalViewDidScroll(_ scrollView: UIScrollView)
}

extension DraggableModalTransition: ModalViewControllerDelegate {
    public func modalViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            switch draggingState {
            case .default:
                draggingState = .ready
            case .ready:
                return
            case .dragging:
                scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
            }
            return
        }
        
        if case .dragging = draggingState {
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
            return
        }
        draggingState = .default
    }
}
