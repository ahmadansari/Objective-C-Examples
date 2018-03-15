//
//  EmojiKeyboardController.swift
//  ChatSerializer
//
//  Created by VentureDive on 3/14/18.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import UIKit

protocol EmojiKeyboardDelegate: class {
    func didSelectEmoji(emoticon:Emoticon)
}

class EmojiKeyboardViewController: UIViewController {
    
    var allEmoticons : [Emoticon]!
    weak var delegate: EmojiKeyboardDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!

    static func instance() -> EmojiKeyboardViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController : UIViewController = storyBoard.instantiateViewController(withIdentifier: "EmojiKeyboardViewController")
        return viewController as! EmojiKeyboardViewController;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        self.allEmoticons = Emoticons.shared.allEmoticons ?? [Emoticon]()
        self.collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension EmojiKeyboardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionView.deselectItem(at: indexPath, animated: true)
        let emoticon = allEmoticons[indexPath.row]
        delegate?.didSelectEmoji(emoticon: emoticon)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.allEmoticons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: EmojiCollectionCell.cellIdentifier, for: indexPath) as! EmojiCollectionCell
        let emoticon = allEmoticons[indexPath.row]
       
        var emoticonImage:UIImage? = nil
        if emoticon.isAnimated() == true {
            emoticonImage = UIImage.gif(name: (emoticon.image)!)
        } else {
            emoticonImage = UIImage.init(named: (emoticon.image)!)
        }
        
        if let emoticonImage = emoticonImage {
          cell.imageView.image = emoticonImage
        }
        return cell
    }
}
