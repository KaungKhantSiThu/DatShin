//
//  SearchViewController+UISearchResultsUpdating.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 04/06/2024.
//

import UIKit

// This extension provides the conformance and implementation for UISearchResultsUpdating.
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.viewModel.currentSearchQuery = searchController.searchBar.text ?? ""
        // The actual search is triggered by the ViewModel's debounced subscriber to currentSearchQuery.
        // No need to call applyAllSectionsSnapshot here directly, as the Combine binding on
        // viewModel.currentSearchQuery handles that.
    }
}
