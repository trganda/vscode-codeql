import java
import semmle.code.java.dataflow.FlowSources

/** The ChannelInboundHandler class */
class ChannelInboundHandler extends Class  {
    ChannelInboundHandler() {
        this.getASourceSupertype*().hasQualifiedName("io.netty.channel", "ChannelInboundHandler")
    }
}

/** The ChannelInboundHandlerl.channelRead method */
class ChannelReadMethod extends Method {
    ChannelReadMethod() {
        this.getDeclaringType() instanceof ChannelInboundHandler and
        this.getName() = ["channelRead", "channelRead0", "messageReceived"]
    }
}

/** The ChannelInboundHandlerl.channelRead(1) source */
class ChannelReadSource extends RemoteFlowSource {
    ChannelReadSource() {
        exists(ChannelReadMethod m | this.asParameter() = m.getParameter(1))
    }

    override string getSourceType() {
        result = "Netty Handler Source"
    }
}

/** The ByteToMessageDecoder class */
class ByteToMessageDecoder extends Class {
    ByteToMessageDecoder() {
        this.getASourceSupertype*().hasQualifiedName("io.netty.handler.codec", "ByteToMessageDecoder")
    }
}

/** The ByteToMessageDecoder.decode method */
class DecodeMethod extends Method {
    DecodeMethod() {
        this.getDeclaringType() instanceof ByteToMessageDecoder and
        this.getName() = ["decode", "decodeLast"]
    }
}

class DecodeSource extends RemoteFlowSource {
    DecodeSource() {
        exists(DecodeMethod m | this.asParameter() = m.getParameter(1) )
    }
    override string getSourceType() {
        result = "Netty Decoder Source"
    }
}

from RemoteFlowSource source
where 
    (
        source instanceof ChannelReadSource or 
        source instanceof DecodeSource
    ) and not source.getLocation().getFile().getRelativePath().matches("%/src/test/%")
select source, source.getEnclosingCallable().getDeclaringType(), source.getSourceType()
