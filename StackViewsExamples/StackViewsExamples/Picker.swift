//
// Created by Boris Schneiderman on 2017-01-29.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation
import UIKit
import StackViews

func startPicker(container: UIViewController, title: String, items: [[String]], selectedIndexes: [Int], completion:  @escaping (Bool, [Int]) -> ()) {
    let vc = PickerViewController(title: title, items: items, selectedIndexes: selectedIndexes, completion: completion)

    container.view.window?.rootViewController?.present(vc, animated: true, completion: nil)
}

class PickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let cancelButton = UIButton()
    let doneButton = UIButton()
    let titleLabel = UILabel()

    let picker = UIPickerView()

    let items: [[String]]

    var indexes: [Int]

    let completion: (Bool, [Int]) -> ()

    var touchOutsideRecognizer: UITapGestureRecognizer!

    init(title: String, items: [[String]], selectedIndexes: [Int], completion: @escaping (Bool, [Int]) -> ()) {

        assert(items.count == selectedIndexes.count)

        self.items = items
        self.indexes = selectedIndexes
        self.completion = completion

        super.init(nibName: nil, bundle: nil)

        picker.dataSource = self
        picker.delegate = self

        titleLabel.textAlignment = .center
        cancelButton.addTarget(self, action: #selector(onCancel), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(onDone), for: .touchUpInside)

        self.touchOutsideRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTouchOutsidePicker))
        self.view.addGestureRecognizer(self.touchOutsideRecognizer)

        self.picker.showsSelectionIndicator = true
        self.picker.backgroundColor = UIColor.white

        (0..<selectedIndexes.count).forEach { self.picker.selectRow(selectedIndexes[$0], inComponent: $0, animated: false) }

        self.view.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
//        self.modalPresentationStyle = .overCurrentContext
        self.modalPresentationStyle = .overFullScreen

        //Title bar
        let _ = stackViews(orientation: .horizontal,
                    parentView: self.view,
                    justify: .stretch,
                    alignment: .start,
                    insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
                    views: [cancelButton, titleLabel, doneButton],
                    widths: [50, nil, 50],
                    heights: [25, 25, 25])

        let _ = stackViews(
                    orientation: .horizontal,
                    parentView: self.view,
                    justify: .stretch,
                    insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
                    views: [picker],
                    heights: [200])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numberOfComponents(`in` pickerView: UIPickerView) -> Int {
        return items.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.items[component].count
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.indexes[component] = row
    }


    func pickerView(_ pickerView: UIPickerView,
                             viewForRow row: Int,
                             forComponent component: Int,
                             reusing view: UIView?) -> UIView {

        let label = (view as? UILabel) ?? UILabel()
        label.textAlignment = .center

        label.text = self.items[component][row]

        return label

    }

    private func onSelectionCompleted(success: Bool) {

        self.view.removeGestureRecognizer(self.touchOutsideRecognizer)

        self.dismiss(animated: true) {
            self.completion(success, self.indexes)
        }
    }

    func onTouchOutsidePicker() {
        onCancel()
    }

    func onDone() {
        onSelectionCompleted(success: true)
    }

    func onCancel() {
        onSelectionCompleted(success: false)
    }

}