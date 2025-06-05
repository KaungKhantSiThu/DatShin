//
//  SearchResultsViewController.swift
//  DatShin
//
//  Created by Cascade on 04/06/2025.
//

import UIKit
import Combine

protocol SearchResultsViewControllerDelegate: AnyObject {
    func searchResultsViewController(_ controller: SearchResultsViewController, didSelectMedia media: Media)
}

class SearchResultsViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: SearchResultsViewModel
    private var cancellables = Set<AnyCancellable>()

    weak var delegate: SearchResultsViewControllerDelegate?

    private var filterSegmentedControl: UISegmentedControl!
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<SearchSection, Media>!
    private let selectionFeedbackGenerator = UISelectionFeedbackGenerator()

    // Placeholder views for different states
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateLabel = UILabel()
    private let errorStateLabel = UILabel()

    enum SearchSection: CaseIterable {
        case results
    }

    // MARK: - Initialization
    init(viewModel: SearchResultsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupFilterSegmentedControl()
        setupCollectionView()
        setupDataSource()
        setupStateViews()
        setupBindings()
        
        selectionFeedbackGenerator.prepare() // Prepare haptics
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure placeholder views are centered if they are visible
        loadingIndicator.center = view.center
        emptyStateLabel.frame = view.bounds.insetBy(dx: 20, dy: 0)
        errorStateLabel.frame = view.bounds.insetBy(dx: 20, dy: 0)
    }

    // MARK: - UI Setup
    private func setupFilterSegmentedControl() {
        filterSegmentedControl = UISegmentedControl(items: SearchResultsViewModel.FilterType.allCases.map { $0.title })
        filterSegmentedControl.selectedSegmentIndex = viewModel.currentFilter.rawValue
        filterSegmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        filterSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterSegmentedControl)
    }

    private func setupCollectionView() {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            filterSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            filterSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.topAnchor.constraint(equalTo: filterSegmentedControl.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        collectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: SearchResultCell.reuseIdentifier)
        collectionView.delegate = self
    }

    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<SearchSection, Media>(collectionView: collectionView) { [weak self] (collectionView, indexPath, mediaItem) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCell.reuseIdentifier, for: indexPath) as? SearchResultCell else {
                return nil
            }
            cell.configure(with: mediaItem, imagesConfiguration: self.viewModel.imagesConfiguration)
            return cell
        }
    }

    private func makeQueueButton(for media: Media) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("+ Queue", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor.systemGray5
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        // Add target/action as needed
        return button
    }

    private func setupStateViews() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        loadingIndicator.hidesWhenStopped = true

        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textColor = .secondaryLabel
        view.addSubview(emptyStateLabel)
        emptyStateLabel.isHidden = true

        errorStateLabel.translatesAutoresizingMaskIntoConstraints = false
        errorStateLabel.textAlignment = .center
        errorStateLabel.numberOfLines = 0
        errorStateLabel.textColor = .systemRed
        view.addSubview(errorStateLabel)
        errorStateLabel.isHidden = true

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyStateLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            errorStateLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            errorStateLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            errorStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setupBindings() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateUI(for: state)
            }
            .store(in: &cancellables)

        viewModel.$imagesConfiguration
            .receive(on: DispatchQueue.main)
            .sink { [weak self] config in
                guard config != nil else { return }
                // Only reload if we have items and the config is new
                if case .loaded(let items, _) = self?.viewModel.state, !items.isEmpty {
                    self?.collectionView.reloadData()
                }
            }
            .store(in: &cancellables)
    }

    private func updateUI(for state: LoadingState<[Media]>) {
        // Hide all state-specific views by default
        loadingIndicator.stopAnimating()
        emptyStateLabel.isHidden = true
        errorStateLabel.isHidden = true
        collectionView.isHidden = true

        switch state {
        case .idle:
            emptyStateLabel.text = "Start typing to search for movies, TV shows, and people."
            emptyStateLabel.isHidden = false
        case .loading:
            loadingIndicator.startAnimating()
        case .loaded(let mediaItems, _):
            collectionView.isHidden = false
            applySnapshot(items: mediaItems, animatingDifferences: true)
        case .empty(let message):
            emptyStateLabel.text = message
            emptyStateLabel.isHidden = false
        case .error(let message):
            errorStateLabel.text = message
            errorStateLabel.isHidden = false
        }
    }

    private func applySnapshot(items: [Media], animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<SearchSection, Media>()
        snapshot.appendSections([.results])
        snapshot.appendItems(items, toSection: .results)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    // MARK: - Actions
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        if let filter = SearchResultsViewModel.FilterType(rawValue: sender.selectedSegmentIndex) {
            viewModel.currentFilter = filter
        }
    }
}

// MARK: - UISearchResultsUpdating
extension SearchResultsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.currentQuery = searchController.searchBar.text ?? ""
    }
}

// MARK: - UISearchBarDelegate
extension SearchResultsViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // The ViewModel handles empty query state.
        // UISearchController should handle its own dismissal or state change automatically.
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Debouncer in ViewModel handles triggering search.
        searchBar.resignFirstResponder() // Dismiss keyboard
    }
}

// MARK: - UICollectionViewDelegate
extension SearchResultsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let mediaItem = dataSource.itemIdentifier(for: indexPath) else { return }
        selectionFeedbackGenerator.selectionChanged()
        delegate?.searchResultsViewController(self, didSelectMedia: mediaItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Check if we're near the end and can load more
        let totalItems = dataSource.snapshot().numberOfItems(inSection: .results)
        if indexPath.item >= totalItems - 2 {
            viewModel.loadMoreResults()
        }
    }
}
