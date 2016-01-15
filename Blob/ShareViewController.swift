//
//  ShareViewController.swift
//  Blob
//
//  Created by Nick Charlton on 22/12/2015.
//  Copyright © 2015 Nick Charlton. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {
  var fetchedURL: String = ""

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      while self.fetchedURL.isEmpty {
        self.fetchURL { url in
          self.fetchedURL = url.absoluteString
        }
      }

      dispatch_async(dispatch_get_main_queue()) {
        let originalContent = self.textView.text
        self.textView.text = "“\(originalContent)” — \(self.fetchedURL)"
        self.validateContent() // we must revalidate once we've updated the content
      }
    }
  }

  override func isContentValid() -> Bool {
    if !fetchedURL.isEmpty {
      let contentWithoutURL = contentText.stringByReplacingOccurrencesOfString(self.fetchedURL, withString: "")

      // a URL requires 23 characters on Twitter
      charactersRemaining = 140 - (contentWithoutURL.characters.count + 23)
    }

    if (charactersRemaining != nil) {
      if Int(charactersRemaining) >= 0 {
        return true
      } else {
        return false
      }
    }

    return true
  }

  override func didSelectPost() {
    // this is the content written in the text box
    print("contentText: \(contentText)")

    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
  }

  override func configurationItems() -> [AnyObject]! {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return []
  }

  func fetchURL(completionHandler: (url: NSURL) -> Void) {
    let extensionItems = extensionContext?.inputItems
    if extensionItems?.count > 0 {
      let item  = extensionItems![0] as! NSExtensionItem
      let attachments = item.attachments

      if let urlProvider = attachments![0] as? NSItemProvider {
        urlProvider.loadItemForTypeIdentifier("public.url", options: nil, completionHandler: { result, error in
          if let url = result as? NSURL {
            completionHandler(url: url)
          }
        })
      }
    }
  }
}