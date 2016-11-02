//
//  RootViewController.swift
//  iOSMidterm
//
//  Created by Borick,Samuel on 11/2/16.
//  Copyright © 2016 Borick,Samuel. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, UIPageViewControllerDelegate {

    var pageViewController: UIPageViewController?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        // Configure the page view controller and add it as a child view controller.
        self.pageViewController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        
        
        if self.pageViewController!.delegate != nil{
            self.pageViewController!.delegate = self
        }else{
            print("error: PageViewController is nil")
        }
        
        //gets the first storyboard
        guard let storyboard = self.storyboard else{
            print("error: no storyboard")
            return
        }
        //gets the first viewcontroller on the first storyboard
        guard let indexedViewController = self.modelController.viewControllerAtIndex(0, storyboard: storyboard) else{
            print("error: no viewController!")
            return
        }
        let startingViewController: DataViewController = indexedViewController
        let viewControllers = [startingViewController]
        //sets up that viewcontroler to be animated during the transition between pages
        if self.pageViewController != nil{
            self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        }

        
        //connects the actual data to the model, which notifies the view via the controller when the data changes
        if self.pageViewController!.dataSource != nil {
            self.pageViewController!.dataSource = self.modelController
        }

        guard let pageViewController = self.pageViewController else{
            print("error: no pageViewController")
            return
        }
        //addes the curent view to the set of views to be switched between
        self.addChildViewController(pageViewController)
        
        guard let pageView = self.pageViewController?.view else{
            print("error: no page View!")
            return
        }
        self.view.addSubview(pageView)

        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        var pageViewRect = self.view.bounds
        if UIDevice.current.userInterfaceIdiom == .pad {
            pageViewRect = pageViewRect.insetBy(dx: 40.0, dy: 40.0)
        }
        
        if self.pageViewController!.view.frame != nil{
            self.pageViewController!.view.frame = pageViewRect
            
            self.pageViewController!.didMove(toParentViewController: self)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var modelController: ModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            _modelController = ModelController()
        }
        
        return _modelController!
    }

    var _modelController: ModelController? = nil

    // MARK: - UIPageViewController delegate methods

    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        if (orientation == .portrait) || (orientation == .portraitUpsideDown) || (UIDevice.current.userInterfaceIdiom == .phone) {
            // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to true, so set it to false here.
            
            //I would like this to be a guard, but the multiple "!"s and the top object being non-optional would result in a multi-layered guard
            if self.pageViewController!.viewControllers![0] != nil{
                let currentViewController = self.pageViewController!.viewControllers![0]
                let viewControllers = [currentViewController]
                self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })
            }
            

            if self.pageViewController!.isDoubleSided != nil{
                self.pageViewController!.isDoubleSided = false
            }
            return .min
        }

        // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
        let currentViewController = self.pageViewController!.viewControllers![0] as! DataViewController
        var viewControllers: [UIViewController]

        
        if let pageViewController = self.pageViewController {
            
            let indexOfCurrentViewController = self.modelController.indexOfViewController(currentViewController)
            if (indexOfCurrentViewController == 0) || (indexOfCurrentViewController % 2 == 0) {
                if let nextViewController = self.modelController.pageViewController(pageViewController, viewControllerAfter: currentViewController){
                    viewControllers = [currentViewController, nextViewController]
                }
            } else {
                if let previousViewController = self.modelController.pageViewController(pageViewController, viewControllerBefore: currentViewController) {
                    viewControllers = [previousViewController, currentViewController]
                }
                
            }
            
            //we can do this because it's gaurinteed to not be nill
            self.pageViewController!.setViewControllers(pageviewControllers, direction: .forward, animated: true, completion: {done in })
        }
        
        

        return .mid
    }


}

