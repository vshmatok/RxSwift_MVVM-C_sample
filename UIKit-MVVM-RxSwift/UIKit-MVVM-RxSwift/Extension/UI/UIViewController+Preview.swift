//
//  UIViewController+Preview.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 27.03.2022.
//

import UIKit

#if DEBUG
import SwiftUI

@available(iOS 13, *)
extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController

        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
    }

    func toPreview() -> some View {
        Preview(viewController: self)
    }
}
#endif
