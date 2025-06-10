//
//  TrainerReviewValidator.swift
//  Backend
//
//  Created by Цховребова Яна on 26.05.2025.
//

public struct TrainerReviewValidator {
    public static let maxCommentLength = 1024
    public static let minRating = 1
    public static let maxRating = 5
    
    public static func validate(rating: Int) -> Bool {
        return rating >= minRating && rating <= maxRating
    }
    
    public static func validate(comment: String) -> Bool {
        return !comment.isEmpty && comment.count < maxCommentLength
    }
}
