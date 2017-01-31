//
// Created by Boris Schneiderman on 2017-01-29.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation
import UIKit
import StackViews

func pickOne(container: UIViewController, titles: [String], selectedIndex: Int? = nil, completion:  @escaping (Int?) -> ()) {
    let vc = PickerViewController(items: titles, selectedIndex: selectedIndex, completion: completion)

    container.view.window?.rootViewController?.present(vc, animated: true, completion: nil)
}

class PickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let picker = UIPickerView()

    let titles: [String]

    var selectedIndex: Int
    let completion: (Int?) -> ()

    var touchOutsideRecognizer: UITapGestureRecognizer!

    init(items: [String], selectedIndex: Int? = nil, completion: @escaping (Int?) -> ()) {
        self.titles = items
        self.selectedIndex = selectedIndex ?? 0
        self.completion = completion

        super.init(nibName: nil, bundle: nil)

        picker.dataSource = self
        picker.delegate = self

        self.touchOutsideRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTouchOutsidePicker))
        self.view.addGestureRecognizer(self.touchOutsideRecognizer)

        self.picker.showsSelectionIndicator = true
        self.picker.backgroundColor = UIColor.white
        self.picker.selectRow(self.selectedIndex, inComponent: 0, animated: false)

        self.view.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
//        self.modalPresentationStyle = .overCurrentContext
        self.modalPresentationStyle = .overFullScreen

        stackViews(
                orientation: .horizontal,
                parentView: self.view,
                insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
                justify: .stretch,
                views: [picker],
                heights: [200])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numberOfComponents(`in` pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.titles.count
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedIndex = row

        onCompletedSelection(isCanceled: false)
    }


    func pickerView(_ pickerView: UIPickerView,
                             viewForRow row: Int,
                             forComponent component: Int,
                             reusing view: UIView?) -> UIView {

        let label = (view as? UILabel) ?? UILabel()
        label.textAlignment = .center

        label.text = self.titles[row]

        return label

    }

    private func onCompletedSelection(isCanceled: Bool) {

        self.view.removeGestureRecognizer(self.touchOutsideRecognizer)

        self.dismiss(animated: true) {
            self.completion(isCanceled ? nil : self.selectedIndex)
        }
    }

    func onTouchOutsidePicker() {
        onCompletedSelection(isCanceled: true)
    }

}