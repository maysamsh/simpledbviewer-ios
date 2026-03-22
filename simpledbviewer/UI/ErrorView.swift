//
//  ErrorView.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-04.
//

import SwiftUI
import UIKit

struct ErrorView: View {
    let error: AppError
    let buttonTitle: String?
    let buttonAction: (() -> Void)?

    init(error: AppError, buttonTitle: String? = nil, buttonAction: (() -> Void)? = nil) {
        self.error = error
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        let errorText = error.errorDescription ?? String(localized: "Something went wrong.")
        VStack(spacing: Spacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(.yellow)
                .accessibilityHidden(true)
            
            Text(errorText)
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundStyle(.primary)
                .accessibilityLabel(errorText)
            
            if let buttonTitle, let buttonAction {
                Button(buttonTitle, action: buttonAction)
                    .padding(.top, Spacing.md2)
            }
            
            Button("Copy error") {
                
                UIPasteboard.general.string = errorText
            }
            .padding(.top, Spacing.md2)
            .accessibilityLabel("Copy error description")
            .accessibilityHint("Copies the error description to the clipboard")
        }
        .padding(Spacing.lg2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

