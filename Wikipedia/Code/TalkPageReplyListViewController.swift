
import UIKit

class TalkPageReplyListViewController: ColumnarCollectionViewController {
    
    var discussion: TalkPageDiscussion! {
        didSet {
            setupFetchedResultsController(with: dataStore)
            if let fetchedResultsController = fetchedResultsController {
                collectionViewUpdater = CollectionViewUpdater(fetchedResultsController: fetchedResultsController, collectionView: collectionView)
                collectionViewUpdater?.delegate = self
                collectionViewUpdater?.performFetch()
            }
        }
    }
    var dataStore: MWKDataStore!
    
    private var fetchedResultsController: NSFetchedResultsController<TalkPageDiscussionItem>?
    private var collectionViewUpdater: CollectionViewUpdater<TalkPageDiscussionItem>?
    
    private let reuseIdentifier = "ReplyListItemCollectionViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        layoutManager.register(ReplyListItemCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier, addPlaceholder: true)
    }
    
    private func setupFetchedResultsController(with dataStore: MWKDataStore) {
        
        let request: NSFetchRequest<TalkPageDiscussionItem> = TalkPageDiscussionItem.fetchRequest()
        request.predicate = NSPredicate(format: "discussion == %@",  discussion)
        request.sortDescriptors = [NSSortDescriptor(key: "discussion", ascending: true)] //todo: I am forced to use this, does this keep original ordering?
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: dataStore.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let fetchedResultsController = fetchedResultsController,
            let sectionsCount = fetchedResultsController.sections?.count else {
                return 0
        }
        return sectionsCount
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let fetchedResultsController = fetchedResultsController,
            let sections = fetchedResultsController.sections,
            section < sections.count else {
                return 0
        }
        return sections[section].numberOfObjects
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let fetchedResultsController = fetchedResultsController,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ReplyListItemCollectionViewCell,
            let title = fetchedResultsController.object(at: indexPath).text else {
                return UICollectionViewCell()
        }
        
        cell.configure(title: title)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, estimatedHeightForItemAt indexPath: IndexPath, forColumnWidth columnWidth: CGFloat) -> ColumnarCollectionViewLayoutHeightEstimate {
        let estimate = ColumnarCollectionViewLayoutHeightEstimate(precalculated: false, height: 100)
        return estimate
    }

}

extension TalkPageReplyListViewController: CollectionViewUpdaterDelegate {
    func collectionViewUpdater<T>(_ updater: CollectionViewUpdater<T>, didUpdate collectionView: UICollectionView) where T : NSFetchRequestResult {
        for indexPath in collectionView.indexPathsForVisibleItems {
            guard let fetchedResultsController = fetchedResultsController,
                let cell = collectionView.cellForItem(at: indexPath) as? DiscussionListItemCollectionViewCell,
                let title = fetchedResultsController.object(at: indexPath).text else {
                    continue
            }
            
            cell.configure(title: title)
        }
    }
    
    func collectionViewUpdater<T>(_ updater: CollectionViewUpdater<T>, updateItemAtIndexPath indexPath: IndexPath, in collectionView: UICollectionView) where T : NSFetchRequestResult {
        //no-op
    }
}
