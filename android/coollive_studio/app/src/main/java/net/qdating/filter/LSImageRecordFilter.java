package net.qdating.filter;

import java.nio.ByteBuffer;

import android.opengl.GLES20;
import android.opengl.GLES30;
import net.qdating.LSConfig;
import net.qdating.utils.Log;

/**
 * RGB录制滤镜
 * @author max
 *
 */
public class LSImageRecordFilter extends LSImageInputFilter {
	private int aPosition;
	private int aTextureCoordinate;
	private int uInputTexture;
	
	/**
	 * Pixel Buffer Object
	 */
	private int[] glPBOBuffers = null;
	private int glPBOCount = 2;
	
	private int glPBOIndex = 0;
	private int glPBONextIndex = 1;
	
	/**
	 * 输出的图像Buffer
	 */
	private byte[] pixelBufferArray = null;
	private int pixelBufferSize = 0;
	
	/**
	 * 录制回调
	 */
	private LSImageRecordFilterCallback callback = null;
	
	public LSImageRecordFilter(LSImageRecordFilterCallback callback) {
		super();
		// TODO Auto-generated constructor stub
		this.callback = callback;
	}

	@Override
	public void uninit() {
		super.uninit();
		destroyGLPBO();
	}

	@Override
	public boolean changeViewPointSize(int viewPointWidth, int viewPointHeight) {
		boolean bFlag = super.changeViewPointSize(viewPointWidth, viewPointHeight);
		if( bFlag ) {
			destroyGLPBO();
			createGLPBO();
		}
		return bFlag;
	}

	@Override
	protected int onDrawFrame(int textureId) {
		int newTextureId = super.onDrawFrame(textureId);

		// 生成录制帧
		recordFrame();
		
		return newTextureId;
	}

	private void createPixelBuffer(int newPixelBufferSize) {
		pixelBufferSize = newPixelBufferSize;
		pixelBufferArray = new byte[pixelBufferSize];
		Log.d(LSConfig.TAG, String.format("LSImageRecordFilter::createPixelBuffer( this : 0x%x, pixelBufferSize : %d )", hashCode(), pixelBufferSize));
	}
	
	private void createGLPBO() {
        // 当前下标
		glPBOIndex = 0;
        
		// 内存Buffer大小, 兼容RGB,RGBA
		int newPixelsBufferSize = viewPointWidth * viewPointHeight * 4; 
		createPixelBuffer(newPixelsBufferSize);
		
		// 创建PBO
		glPBOBuffers = new int[glPBOCount];
		GLES30.glGenBuffers(glPBOCount, glPBOBuffers, 0);

		for(int i = 0; i < glPBOCount; i++) {
	        GLES30.glBindBuffer(GLES30.GL_PIXEL_PACK_BUFFER, glPBOBuffers[i]);
	        GLES30.glBufferData(GLES30.GL_PIXEL_PACK_BUFFER, newPixelsBufferSize, null, GLES30.GL_STATIC_READ);
		}

        // 解除PBO绑定
        GLES30.glBindBuffer(GLES30.GL_PIXEL_PACK_BUFFER, 0);
        
        Log.d(LSConfig.TAG, String.format("LSImageRecordFilter::createGLPBO( this : 0x%x, glPBOCount : %d ) ", hashCode(), glPBOCount));
	}
	
	private void destroyGLPBO() {
		// 销毁PBO
	    if (glPBOBuffers != null) {
            GLES30.glDeleteBuffers(glPBOCount, glPBOBuffers, 0);
			String method = String.format("glDeleteBuffers( glPBOBuffers : %d )", glPBOBuffers[0]);
			checkGLError(method, null);
            glPBOBuffers = null;
        }
	}
	
	private void recordFrame() {
		// 用GLES20的直接读取Piexl非常慢
//		GLES20.glReadPixels(0, 0, outputWidth, outputHeight, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, pixelBuffer);
		if( glPBOBuffers != null ) {
			// 绑定PBO
			GLES30.glBindBuffer(GLES30.GL_PIXEL_PACK_BUFFER, glPBOBuffers[glPBOIndex]);
			// 通过JNI调用读取Pixel, 传入NULL指针避免GPU数据到内存的复制
			LSImageUtilJni.GLReadPixels(0, 0, viewPointWidth, viewPointHeight, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE);
			// 绑定下一个PBO
			GLES30.glBindBuffer(GLES30.GL_PIXEL_PACK_BUFFER, glPBOBuffers[glPBONextIndex]);
			ByteBuffer byteBuffer = (ByteBuffer) GLES30.glMapBufferRange(GLES30.GL_PIXEL_PACK_BUFFER, 0, pixelBufferSize, GLES30.GL_MAP_READ_BIT);
			GLES30.glUnmapBuffer(GLES30.GL_PIXEL_PACK_BUFFER);
			GLES30.glBindBuffer(GLES30.GL_PIXEL_PACK_BUFFER, 0);
			
			glPBOIndex = (glPBOIndex + 1) % 2;
			glPBONextIndex = (glPBONextIndex + 1) % 2;

			if( callback != null ) {
				if( byteBuffer != null ) {
					// 回调已经处理过的视频帧
					int size = byteBuffer.remaining();
					byteBuffer.get(pixelBufferArray, 0, size);
					callback.onRecordFrame(pixelBufferArray, size, viewPointWidth, viewPointHeight);
				}
			}
		}
	}
}
