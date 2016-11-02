
typealias Block = ()->()

public static class BroadcastManager {
	
	private let subscriptions = Dictionary<String,List<(Object,Block)>>()

	//func subscribe(_ object: Object, toBroadcast broadcast: String, block: (Dictionary<String,Any>)->()) {
	//}

	func subscribe(_ object: Object, toBroadcast broadcast: String, block: ()->()) {
		var subs = subscriptions[broadcast]
		if subs == nil {
			subs = List<(Object,Block)>()
			subscriptions[broadcast] = subs
		}
		subs!.Add((object, block))
	}

	func subscribe(_ object: Object, toBroadcasts broadcasts: List<String>, block: ()->()) {
		for b in broadcasts {
			subscribe(object, toBroadcast: b, block: block)
		}
	}

	#if NOUGAT
	func subscribe(_ object: Object, selector: SEL, toBroadcast broadcast: String) {
		NSNotificationCenter.defaultCenter.addObserver(object, selector: selector, name: broadcast, object: nil)
	}
	#endif

	func unsubscribe(_ object: Object, fromBroadcast broadcast: String?) {
		#if NOUGAT
		NSNotificationCenter.defaultCenter.removeObserver(object, name: broadcast, object: nil)
		#endif
		
		if let subs = subscriptions[broadcast] {
			for s in subs? {
				if s.0 == object {
					subs.remove(s)
				}
			}
		}
	}

	func unsubscribe(_ object: Object) {
		#if NOUGAT
		NSNotificationCenter.defaultCenter.removeObserver(object)
		#endif

		for k in subscriptions.keys {
			if let subs = subscriptions[k] {
				for s in subs? {
					if s.0 == object {
						subs.remove(s)
					}
				}
			}
		}
	}

	func submitBroadcast(_ broadcast: String, object: Object? = nil, data: Dictionary<String,Object>? = nil, syncToMainThread: Boolean = false) {
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
