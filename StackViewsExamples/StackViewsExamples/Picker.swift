//
// Created by Boris Schneiderman on 2017-01-29.
// Copyright (c) 2017 bormind. All rights reserved.
//

import Foundation
import UIKit
import StackViews

func startPicker(container: UIViewController, title: String, items: [[String]], selectedIndexes: [Int], componentTitles: [String]? = nil, completion:  @escaping ([Int]) -> ()) {
    let vc = PickerViewController(title: title, items: items, selectedIndexes: selectedIndexes, componentTitles: componentTitles, completion: completion)

    container.view.window?.rootViewController?.present(vc, animated: true, completion: nil)
}

class PickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let leftSpacer = UIView()
    let doneButton = UIButton()
    let titleLabel = UILabel()

    let picker = UIPickerView()

    let items: [[String]]

    var indexes: [Int]

    let completion: ([Int]) -> ()

    var touchOutsideRecognizer: UITapGestureRecognizer!

    let initialSelection: [Int]

    init(title: String, items: [[String]], selectedIndexes: [Int], componentTitles: [String]? = nil, completion: @escaping ([Int]) -> ()) {

        assert(items.count == selectedIndexes.count)
        assert(componentTitles == nil || items.count == componentTitles!.count)

        self.items = items
        self.initialSelection = selectedIndexes
        self.indexes = selectedIndexes
        self.completion = completion

        super.init(nibName: nil, bundle: nil)

        picker.dataSource = self
        picker.delegate = self

        titleLabel.textAlignment = .center
        titleLabel.text = title

        doneButton.addTarget(self, action: #selector(onDone), for: .touchUpInside)
        doneButton.setTitle("X", for: .normal)
        doneButton.setTitleColor(UIColor.blue, for: .normal)
        doneButton.backgroundColor = UIColor.lightGray

        self.touchOutsideRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTouchOutsidePicker))
        self.view.addGestureRecognizer(self.touchOutsideRecognizer)

        self.picker.showsSelectionIndicator = true

        if let componentTitles = componentTitles {
            renderComponentTitles(componentTitles, picker: self.picker)
        }

        (0..<selectedIndexes.count).forEach { self.picker.selectRow(selectedIndexes[$0], inComponent: $0, animated: false) }

        self.view.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
//        self.modalPresentationStyle = .overCurrentContext
        self.modalPresentationStyle = .overFullScreen

        let panelView = createPanelView(container: self.view)

        //Title bar
        let _ = stackViews(orientation: .horizontal,
                    justify: .fill,
                    align: .start,
                    parentView: panelView,
                    insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
                    views: [leftSpacer, titleLabel, doneButton],
                    widths: [50, nil, 50],
                    heights: [25, 25, 25])

        //picker
        let _ = stackViews(
                    orientation: .horizontal,
                    justify: .fill,
                    align: .fill,
                    parentView: panelView,
                    insets: UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0),
                    views: [picker])
    }

    private func renderComponentTitles(_ titles: [String], picker: UIPickerView)  {
        let labels: [UIView] = titles.map {
            let label = UILabel()
            label.text = $0
            label.textAlignment = .center
            label.backgroundColor = UIColor.barColor
            return label
        }

        stackViews(
                orientation: .horizontal,
                justify: .fill,
                align: .start,
                parentView: picker,
                views: labels)
    }

    private func createPanelView(container: UIView) -> UIView {
        let panel = UIView()
        panel.backgroundColor = UIColor.barColor

        let _ = stackViews(
                    orientation: .horizontal,
                    justify: .fill,
                    align: .center,
                    parentView: container,
                    insets: UIEdgeInsets(horizontal: 20),
                    views: [panel],
                    heights: [250])

        return panel
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

    private func onSelectionCompleted() {

        self.view.removeGestureRecognizer(self.touchOutsideRecognizer)

        self.dismiss(animated: true) {
            self.completion(self.indexes)
        }
    }

    func onTouchOutsidePicker() {
        onSelectionCompleted()
    }

    func onDone() {
        onSelectionCompleted()
    }


}