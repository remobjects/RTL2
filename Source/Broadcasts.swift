
typealias Block = ()->()

public static class RemObjects.Elements.RTL.BroadcastManager {
	
	private let subscriptions = Dictionary<String,List<(Object,Block)>>()

	//func subscribe(_ object: Object, toBroadcast broadcast: String, block: (Dictionary<String,Any>)->()) {
	//}

	public func subscribe(_ receiver: Object, toBroadcast broadcast: String, block: ()->()) {
		var subs = subscriptions[broadcast]
		if subs == nil {
			subs = List<(Object,Block)>()
			subscriptions[broadcast] = subs
		}
		subs!.Add((receiver, block))
	}

	public func subscribe(_ receiver: Object, toBroadcasts broadcasts: List<String>, block: ()->()) {
		for b in broadcasts {
			subscribe(receiver, toBroadcast: b, block: block)
		}
	}

	#if NOUGAT
	public func subscribe(_ receiver: Object, selector: SEL, toBroadcast broadcast: String, object: Object? = nil) {
		NSNotificationCenter.defaultCenter.addObserver(receiver, selector: selector, name: broadcast, object: object)
	}
	#endif

	public func unsubscribe(_ receiver: Object, fromBroadcast broadcast: String?) {
		#if NOUGAT
		NSNotificationCenter.defaultCenter.removeObserver(receiver, name: broadcast, object: nil)
		#endif
		
		if let subs = subscriptions[broadcast] {
			for s in subs? {
				if s.0 == receiver {
					subs.remove(s)
				}
			}
		}
	}

	public func unsubscribe(_ receiver: Object) {
		#if NOUGAT
		NSNotificationCenter.defaultCenter.removeObserver(receiver)
		#endif

		for k in subscriptions.keys {
			if let subs = subscriptions[k] {
				for s in subs? {
					if s.0 == receiver {
						subs.remove(s)
					}
				}
			}
		}
	}

	public func submitBroadcast(_ broadcast: String, object: Object? = nil, data: ImmutableDictionary<String,Object>? = nil, syncToMainThread: Boolean = false) {
		#if NOUGAT
		if syncToMainThread {
			dispatch_async(dispatch_get_main_queue()) {
				NSNotificationCenter.defaultCenter.postNotificationName(broadcast, object: object, userInfo: data)
			}
		} else {
			NSNotificationCenter.defaultCenter.postNotificationName(broadcast, object: object, userInfo: data)
		}
		#endif
		
		for s in subscriptions[broadcast] {
			if syncToMainThread {
				#if NOUGAT
				dispatch_async(dispatch_get_main_queue()) {
					s.1()
				}
				#endif
				#if JAVA
				/*ThreadUtils.runOnUiThread() {
					s.1()
				}*/
				#endif
			}
			else {
				s.1()
			}
		}
	}
}
