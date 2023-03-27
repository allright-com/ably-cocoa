import Ably
import Nimble
import XCTest

// Swift isn't yet smart enough to do this automatically when bridging Objective-C APIs
extension ARTRealtimeChannels: Sequence {
    public func makeIterator() -> NSFastEnumerationIterator {
        return NSFastEnumerationIterator(iterate())
    }
}

class RealtimeClientChannelsTests: XCTestCase {
    // RTS2
    func test__001__Channels__should_exist_methods_to_check_if_a_channel_exists_or_iterate_through_the_existing_channels() {
        let client = ARTRealtime(options: AblyTests.commonAppSetup())
        defer { client.dispose(); client.close() }
        var disposable = [String]()

        let channelName1 = uniqueChannelName(prefix: "1")
        let channelName2 = uniqueChannelName(prefix: "2")
        let channelName3 = uniqueChannelName(prefix: "3")

        disposable.append(client.channels.get(channelName1).name)
        disposable.append(client.channels.get(channelName2).name)
        disposable.append(client.channels.get(channelName3).name)

        XCTAssertNotNil(client.channels.get(channelName2))
        XCTAssertTrue(client.channels.exists(channelName2))
        XCTAssertFalse(client.channels.exists("testX"))

        for channel in client.channels {
            XCTAssertTrue(disposable.contains((channel as! ARTRealtimeChannel).name))
        }
    }

    // RTS3

    // RTS3a
    func test__002__Channels__get__should_create_a_new_Channel_if_none_exists_or_return_the_existing_one() {
        let options = AblyTests.commonAppSetup()
        let client = ARTRealtime(options: options)
        defer { client.dispose(); client.close() }

        XCTAssertEqual(client.channels.internal.collection.count, 0)
        let channelName = uniqueChannelName()
        let channel = client.channels.get(channelName)
        XCTAssertEqual(channel.name, "\(options.channelNamePrefix!)-\(channelName)")

        XCTAssertEqual(client.channels.internal.collection.count, 1)
        XCTAssertTrue(client.channels.get(channelName).internal === channel.internal)
        XCTAssertEqual(client.channels.internal.collection.count, 1)
    }

    // RTS3b
    func test__003__Channels__get__should_be_possible_to_specify_a_ChannelOptions() {
        let client = ARTRealtime(options: AblyTests.commonAppSetup())
        defer { client.dispose(); client.close() }
        let options = ARTRealtimeChannelOptions()
        let channel = client.channels.get(uniqueChannelName(), options: options)
        XCTAssertTrue(channel.options === options)
    }

    // RTS3c
    func test__004__Channels__get__accessing_an_existing_Channel_with_options_should_update_the_options_and_then_return_the_object() {
        let client = ARTRealtime(options: AblyTests.commonAppSetup())
        defer { client.dispose(); client.close() }
        let channelName = uniqueChannelName()
        XCTAssertNil(client.channels.get(channelName).options)
        let options = ARTRealtimeChannelOptions()
        let channel = client.channels.get(channelName, options: options)
        XCTAssertTrue(channel.options === options)
    }

    // RTS4

    func test__005__Channels__release__should_release_a_channel() {
        let client = ARTRealtime(options: AblyTests.commonAppSetup())
        defer { client.dispose(); client.close() }

        let channelName = uniqueChannelName()
        let channel = client.channels.get(channelName)
        channel.subscribe { _ in
            fail("shouldn't happen")
        }
        channel.presence.subscribe { _ in
            fail("shouldn't happen")
        }
        waitUntil(timeout: testTimeout) { done in
            client.channels.release(channelName) { errorInfo in
                XCTAssertNil(errorInfo)
                XCTAssertEqual(channel.state, ARTRealtimeChannelState.detached)
                done()
            }
        }

        let sameChannel = client.channels.get(channelName)
        waitUntil(timeout: testTimeout) { done in
            sameChannel.subscribe { _ in
                sameChannel.presence.enterClient("foo", data: nil) { _ in
                    delay(0.0) { done() } // Delay to make sure EventEmitter finish its cycle.
                }
            }
            sameChannel.publish("foo", data: nil)
        }
    }
}
