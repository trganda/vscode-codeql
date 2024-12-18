/**
 * @name attack surface
 * @kind problem
 * @problem.severity warning
 * @id org/trganda/java/dubbo
 */

import java
import semmle.code.java.dataflow.FlowSources

/** The ChannelInboundHandler class */
class ChannelInboundHandler extends Class {
    ChannelInboundHandler() {
        this.getASourceSupertype*().hasQualifiedName("io.netty.channel", "ChannelInboundHandler")
    }
}

/** The ByteToMessageDecoder class */
class ByteToMessageDecoder extends Class {
    ByteToMessageDecoder() {
        this.getASourceSupertype*().hasQualifiedName("io.netty.handler.codec", "ByteToMessageDecoder")
    }
}

/** The ChannelInboundHandlerl.channelRead(1) source */
class ChannelReadMethod extends Method {
    ChannelReadMethod() {
      this.getName() = ["channelRead", "channelRead0", "messageReceived"] and
      this.getDeclaringType() instanceof ChannelInboundHandler
    }
}

/** The ByteToMessageDecoder.decode(1) source */
class ByteDecoderMethod extends Method {
    ByteDecoderMethod() {
        this.getDeclaringType() instanceof ByteToMessageDecoder and
        this.getName() = ["decode", "decodeLast"]
    }
}

/** RemoteFlowSource of Dubbo Framework */
class DubboSource extends RemoteFlowSource {
    DubboSource() {
        exists(ChannelReadMethod m1, ByteDecoderMethod m2 | m1.getParameter(1) = this.asParameter() or m2.getParameter(1) = this.asParameter())
    }

    override string getSourceType() {
        result = "Netty Source"
    }
}

from DubboSource romteSource
where not 
    romteSource.getLocation().getFile().getRelativePath().matches("%/src/test%")
select romteSource, romteSource.getEnclosingCallable().getDeclaringType(), romteSource.getSourceType()
