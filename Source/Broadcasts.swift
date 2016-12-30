
typealias Block = ()->()

public static class RemObjects.Elements.RTL.BroadcastManager {
	
	private let subscriptions = Dictionary<String,List<(Object,Block)>>()

	//func subscribe(_ object: Object, toBroadcast broadcast: String, block: (Dictionary<String,Any>)->()) {
	//}

	public func subscribe(_ receiver: Object, toBroadcast broadcast: String, block: ()->()) {
		__lock self {
			var subs = subscriptions[broadcast]
			if subs == nil {
				subs = List<(Object,Block)>()
				subscriptions[broadcast] = subs
			}
			subs!.Add((receiver, block))
		}
	}

	public func subscribe(_ receiver: Object, toBroadcasts broadcasts: List<String>, block: ()->()) {
		for b in broadcasts {
			subscribe(receiver, toBroadcast: b, block: block)
		}
	}

	#if TOFFEE
	public func subscribe(_ receiver: Object, selector: SEL, toBroadcast broadcast: String, object: Object? = nil) {
		NSNotificationCenter.defaultCenter.addObserver(receiver, selector: selector, name: broadcast, object: object)
	}
	#endif

	public func unsubscribe(_ receiver: Object, fromBroadcast broadcast: String?) {
		#if TOFFEE
		NSNotificationCenter.defaultCenter.removeObserver(receiver, name: broadcast, object: nil)
		#endif
		
		__lock self {
			if let subs = subscriptions[broadcast] {
				for s in subs? {
					if s.0 == receiver {
						subs.Remove(s)
					}
				}
			}
		}
	}

	public func unsubscribe(_ receiver: Object) {
		#if TOFFEE
		NSNotificationCenter.defaultCenter.removeObserver(receiver)
		#endif

		__lock self {
			for k in subscriptions.Keys {
				if let subs = subscriptions[k] {
					for s in subs? {
						if s.0 == receiver {
							subs.Remove(s)
						}
					}
				}
			}
		}
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
		#warning syncToMainThreadIfNeeded() is not implemented for non-Toffee
		if sync {
			throw Exception("syncToMainThreadIfNeeded() is not implemented for non-Toffee platforms, yet.")
		} else {
			block()
		}
		#endif
	}

	public func submitBroadcast(_ broadcast: String, object: Object? = nil, data: ImmutableDictionary<String,Object>? = nil, syncToMainThread: Boolean = false) {
		syncToMainThreadIfNeeded(sync: syncToMainThread) {

			#if TOFFEE
			NSNotificationCenter.defaultCenter.postNotificationName(broadcast, object: object, userInfo: data)
			#endif
		
			__lock self {
				for s in subscriptions[broadcast] {
					s.1()
				}
			}
		}
	}
}
