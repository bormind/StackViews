//
//  ViewController.swift
//  StackViewsExamples
//
//  Created by Boris Schneiderman on 2017-01-28.
//  Copyright © 2017 bormind. All rights reserved.
//

import UIKit
import StackViews

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    let tableCellId = "TableCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(MenuTableCell.self, forCellReuseIdentifier: tableCellId)

        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellId, for: indexPath) as! MenuTableCell

        cell.setMenuItem(text: "Interactive Example")

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = InteractiveExampleViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

