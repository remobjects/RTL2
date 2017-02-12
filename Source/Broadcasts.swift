
typealias Block = (_ sender: Notification)->()

#if TOFFEE
public __mapped class Notification => NSNotification {
	public var data: ImmutableDictionary<String,Object>? {
		return __mapped.userInfo
	}
	public var object: Object? {
		return __mapped.object
	}

	init(object: Object?, data: ImmutableDictionary<String,Object>?) {
		return NSNotification(name: "Notification", object: object, userInfo: data)
	}
}
#else
public class Notification {
	public private(set) var object: Object?
	public private(set) var data: ImmutableDictionary<String,Object>?

	init(object: Object?, data: ImmutableDictionary<String,Object>?) {
		self.object = object
		self.data = data
	}
}
#endif

#if TOFFEE
fileprivate class RemObjects.Elements.RTL.BroadcastManagerSubscription {
	/*weak*/ var receiver: Object
	weak var object: Object?
	var token: id;
	init (_ receiver: Object, _ object: Object?, _ token: id) {
		self.receiver = receiver
		self.object = object
		self.token = token
	}
}
#endif

public static class RemObjects.Elements.RTL.BroadcastManager {

	#if TOFFEE
	private let subscriptions = Dictionary<String,List<BroadcastManagerSubscription>>() // receiver, object, token
	#else
	private let subscriptions = Dictionary<String,List<(Object,Object?,Block)>>()    // receiver, block
	#endif

	#if ECHOES
	private let lock = System.Threading.ReaderWriterLockSlim(System.Threading.LockRecursionPolicy.SupportsRecursion)
	#endif

	private func lockRead(_ callback: () -> () ) {
		#if ECHOES
		lock.EnterReadLock()
		defer { lock.ExitReadLock() }
		callback()
		#else
		__lock self {
			callback()
		}
		#endif
	}

	private func lockWrite(_ callback: () -> () ) {
		#if ECHOES
		lock.EnterWriteLock()
		defer { lock.ExitWriteLock() }
		callback()
		#else
		__lock self {
			callback()
		}
		#endif
	}

	//func subscribe(_ object: Object, toBroadcast broadcast: String, block: (Dictionary<String,Any>)->()) {
	//}

	public func subscribe(_ receiver: Object, toBroadcast broadcast: String, block: (_ sender: Notification)->()) {
		subscribe(receiver, toBroadcast: broadcast, block: block, object: nil)
	}

	public func subscribe(_ receiver: Object, toBroadcast broadcast: String, block: (_ sender: Notification)->(), object: Object?) {
		#if TOFFEE
		let token = NSNotificationCenter.defaultCenter.addObserver(for: broadcast, object: object, queue: nil, usingBlock: { n in block(n) });
		lockWrite() {
			var subs = subscriptions[broadcast]
			if subs == nil {
				subs = List<BroadcastManagerSubscription>()
				subscriptions[broadcast] = subs
			}
			subs!.Add(BroadcastManagerSubscription(receiver, object, token))
		}
		#else
		lockWrite() {
			var subs = subscriptions[broadcast]
			if subs == nil {
				subs = List<(Object,Object?,Block)>()
				subscriptions[broadcast] = subs
			}
			subs!.Add((receiver, object, block))
		}
		#endif
	}

	public func subscribe(_ receiver: Object, toBroadcasts broadcasts: List<String>, block: (_ sender: Notification)->()) {
		subscribe(receiver, toBroadcasts: broadcasts, block: block, object: nil)
	}

	public func subscribe(_ receiver: Object, toBroadcasts broadcasts: List<String>, block: (_ sender: Notification)->(), object: Object?) {
		for b in broadcasts {
			subscribe(receiver, toBroadcast: b, block: block, object: object)
		}
	}

	#if TOFFEE
	public func subscribe(_ receiver: Object, toBroadcast broadcast: String, selector: SEL, object: Object? = nil) {
		NSNotificationCenter.defaultCenter.addObserver(receiver, selector: selector, name: broadcast, object: object)
	}
	#endif

	public func unsubscribe(_ receiver: Object, fromBroadcast broadcast: String, object: Object? = nil) {
		#if TOFFEE
		NSNotificationCenter.defaultCenter.removeObserver(receiver, name: broadcast, object: nil)
		lockWrite() {
			if let subs = subscriptions[broadcast] {
				for s in subs.UniqueCopy() {
					if s.receiver == nil || (s.receiver == receiver && (s.object == object || s.object == nil || object == nil)) {
						NSNotificationCenter.defaultCenter.removeObserver(s.token)
						subs.Remove(s)
					}
				}
				if subs.Count == 0 {
					subscriptions.Remove(broadcast)
				}
			}
		}
		#else
		lockWrite() {
			if let subs = subscriptions[broadcast] {
				for s in subs.UniqueCopy() {
					if s.0 == receiver {
						subs.Remove(s)
					}
				}
				if subs.Count == 0 {
					subscriptions.Remove(broadcast)
				}
			}
		}
		#endif
	}

	public func unsubscribe(_ receiver: Object) {
		#if TOFFEE
		NSNotificationCenter.defaultCenter.removeObserver(receiver)
		lockWrite() {
			for k in subscriptions.Keys {
				if let subs = subscriptions[k] {
					for s in subs.UniqueCopy() {
						if s.receiver == receiver || s.receiver == nil {
							NSNotificationCenter.defaultCenter.removeObserver(s.token)
							subs.Remove(s)
						}
					}
					if subs.Count == 0 {
						subscriptions.Remove(k)
					}
				}
			}
		}
		#else
		lockWrite() {
			for k in subscriptions.Keys {
				if let subs = subscriptions[k] {
					for s in subs.UniqueCopy() {
						if s.0 == receiver {
							subs.Remove(s)
						}
					}
					if subs.Count == 0 {
						subscriptions.Remove(k)
					}
				}
			}
		}
		#endif
	}

	@inline(always)
	private func syncToMainThreadIfNeeded(sync: Boolean, block: () -> ()) {
		#if TOFFEE
		if sync {
			dispatch_async(dispatch_get_main_queue(), block)
		} else {
			block()
		}
		#else
		if sync {
			#warning syncToMainThreadIfNeeded() is not implemented for non-Toffee
			block()
		} else {
			block()
		}
		#endif
	}

	public func submitBroadcast(_ broadcast: String, object: Object? = nil, data: ImmutableDictionary<String,Object>? = nil, syncToMainThread: Boolean = false) {
		syncToMainThreadIfNeeded(sync: syncToMainThread) {

			#if TOFFEE
			NSNotificationCenter.defaultCenter.postNotificationName(broadcast, object: object, userInfo: data)
			#else
			lockRead() {
				for s in subscriptions[broadcast]?.UniqueCopy() {
					if s.1 == nil || s.1 == object {
						s.2(Notification(object: object, data: data))
					}
				}
			}
			#endif
		}
	}
}