package com.lambdaworks;

import java.util.concurrent.TimeUnit;

import com.lambdaworks.redis.TestEventLoopGroupProvider;
import com.lambdaworks.redis.resource.ClientResources;
import com.lambdaworks.redis.resource.DefaultClientResources;

/**
 * Client-Resources suitable for testing. Uses {@link com.lambdaworks.redis.TestEventLoopGroupProvider} to preserve the event
 * loop groups between tests. Every time a new {@link TestClientResources} instance is created, shutdown hook is added
 * {@link Runtime#addShutdownHook(Thread)}.
 * 
 * @author <a href="mailto:mpaluch@paluch.biz">Mark Paluch</a>
 */
public class TestClientResources {

    public static ClientResources create() {
        final DefaultClientResources resources = new DefaultClientResources.Builder().eventLoopGroupProvider(
                new TestEventLoopGroupProvider()).build();

        Runtime.getRuntime().addShutdownHook(new Thread() {
            @Override
            public void run() {
                try {
                    resources.shutdown(100, 100, TimeUnit.MILLISECONDS).get(10, TimeUnit.SECONDS);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });

        return resources;
    }
}
