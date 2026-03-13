//
//  ReviewRequester.swift
//  DokuMan
//
//  Created by Codex on 13.03.26.
//

import StoreKit
import UIKit

enum ReviewRequester {
    private static let documentsCountKey = "review_documents_count"
    private static let numbersCountKey = "review_numbers_count"
    private static let totalSavesKey = "review_total_saves"
    private static let lastPromptTotalKey = "review_last_prompt_total"
    private static let hasReviewedKey = "review_has_reviewed"

    static func recordDocumentSaved() {
        let documentsCount = increment(key: documentsCountKey)
        let totalSaves = increment(key: totalSavesKey)
        maybeRequestReview(documentsCount: documentsCount, numbersCount: currentCount(key: numbersCountKey), totalSaves: totalSaves)
    }

    static func recordNumberSaved() {
        let numbersCount = increment(key: numbersCountKey)
        let totalSaves = increment(key: totalSavesKey)
        maybeRequestReview(documentsCount: currentCount(key: documentsCountKey), numbersCount: numbersCount, totalSaves: totalSaves)
    }

    private static func maybeRequestReview(documentsCount: Int, numbersCount: Int, totalSaves: Int) {
        guard !UserDefaults.standard.bool(forKey: hasReviewedKey) else { return }

        let shouldPromptAtThreshold = (documentsCount == 3) || (numbersCount == 3)
        let shouldPromptEveryTen = (totalSaves > 3) && ((totalSaves - 3) % 10 == 0)

        guard shouldPromptAtThreshold || shouldPromptEveryTen else { return }

        let lastPromptTotal = UserDefaults.standard.integer(forKey: lastPromptTotalKey)
        guard lastPromptTotal != totalSaves else { return }
        UserDefaults.standard.set(totalSaves, forKey: lastPromptTotalKey)

        requestReview()
    }

    private static func requestReview() {
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first else { return }
            AppStore.requestReview(in: scene)
        }
    }

    private static func increment(key: String) -> Int {
        let newValue = UserDefaults.standard.integer(forKey: key) + 1
        UserDefaults.standard.set(newValue, forKey: key)
        return newValue
    }

    private static func currentCount(key: String) -> Int {
        UserDefaults.standard.integer(forKey: key)
    }
}
