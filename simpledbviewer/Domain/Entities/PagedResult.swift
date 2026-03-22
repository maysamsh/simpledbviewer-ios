//
//  PagedResult.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-11.
//

struct PagedResult<T> {
    let items: [T]
    let nextToken: String?

    var hasMore: Bool { nextToken != nil }
}
