package com.lambdaworks.redis;

import java.util.concurrent.TimeUnit;

import com.lambdaworks.redis.resource.DefaultEventLoopGroupProvider;

import io.netty.util.concurrent.DefaultPromise;
import io.netty.util.concurrent.EventExecutorGroup;
import io.netty.util.concurrent.ImmediateEventExecutor;
import io.netty.util.concurrent.Promise;

/**
 * A {@link com.lambdaworks.redis.resource.EventLoopGroupProvider} suitable for testing. Preserves the event loop groups between
 * tests. Every time a new {@link TestEventLoopGroupProvider} instance is created, shutdown hook is added
 * {@link Runtime#addShutdownHook(Thread)}.
 * 
 * @author <a href="mailto:mpaluch@paluch.biz">Mark Paluch</a>
 */
public class TestEventLoopGroupProvider extends DefaultEventLoopGroupProvider {

    public TestEventLoopGroupProvider() {
        super(10);
        Runtime.getRuntime().addShutdownHook(new Thread() {
            @Override
            public void run() {
                try {
                    TestEventLoopGroupProvider.this.shutdown(100, 100, TimeUnit.MILLISECONDS).get(10, TimeUnit.SECONDS);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });
    }

    @Override
    public Promise<Boolean> release(EventExecutorGroup eventLoopGroup, long quietPeriod, long timeout, TimeUnit unit) {
        DefaultPromise<Boolean> result = new DefaultPromise<Boolean>(ImmediateEventExecutor.INSTANCE);
        result.setSuccess(true);

        return result;
    }
}
