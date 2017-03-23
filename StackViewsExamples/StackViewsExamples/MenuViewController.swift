//
//  ViewController.swift
//  StackViewsExamples
//
//  Created by Boris Schneiderman on 2017-01-28.
//  Copyright © 2017 bormind. All rights reserved.
//

import UIKit
import StackViews

fileprivate struct MenuItem {
    let title: String
    let `class`: UIViewController.Type

    init(_ title: String, _ `class`: UIViewController.Type) {
        self.title = title
        self.class = `class`
    }
}

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let tableView = UITableView()

    let tableCellId = "TableCell"


    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = false
        
        embedView(tableView, inViewController: self)

        tableView.register(MenuTableCell.self, forCellReuseIdentifier: tableCellId)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.reloadData()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate let examples: [MenuItem] = [
            MenuItem("Interactive Example", InteractiveExampleViewController.self),
            MenuItem("UIStackView Docs Example", DocsExampleViewController.self)
    ]

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellId, for: indexPath) as! MenuTableCell

        cell.setMenuItem(text: examples[indexPath.row].title)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = examples[indexPath.row].class.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

