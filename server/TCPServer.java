import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.InetAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketException;
import java.util.ArrayList;
import java.util.List;
import java.util.Vector;

public class TCPServer {
	public final static int port = 6969;

	public TCPServer() {
		ServerSocket theServer;
		Socket theConnection;
		try {
			theServer = new ServerSocket(port);
			System.out.println(
					"Server running on port " + port + " localhost and ip " + theServer.getLocalSocketAddress().toString() + ".");

			while (true) {
				theConnection = theServer.accept();
				new ThreadedHandler(this, theConnection).start();
			}
		} catch (IOException e) {
			System.err.println(e);
		}
	}

	public Vector<ThreadedHandler> cls = new Vector<ThreadedHandler>();
	public Vector<String> messageList = new Vector<String>();
	public Vector<String> files = new Vector<String>();

	public static void main(String[] args) {
		new TCPServer();
	}

	public class ThreadedHandler extends Thread {
		TCPServer server;
		public Socket incoming;
		public DataInputStream dis;
		public DataOutputStream dos;
		public String userJson;

		public ThreadedHandler(TCPServer crsv, Socket i) {
			this.server = crsv;
			this.incoming = i;
			try {
				this.dis = new DataInputStream(incoming.getInputStream());
				this.dos = new DataOutputStream(incoming.getOutputStream());
//            for (int j=0; j<this.crsv.cls.size(); j++) {
//
//            }
			} catch (IOException e) {
			}
		}

		public void run() {
			String dataInput = "";
			try {
				// Kiá»ƒm tra Ä‘á»ƒ thÃªm ngÆ°á»�i tham gia
				dataInput = dis.readLine();
				System.out.println("Handle message: " + dataInput);
				String cmd = dataInput.substring(0, dataInput.indexOf("_"));
				String msg = dataInput.substring(dataInput.indexOf("_") + 1);
				if (!cmd.equals("userIn"))
					incoming.close();
//				System.out.println("New member join: " + msg);
				this.userJson = msg;
				this.server.cls.add(this);
//			for (int j=0; j<this.crsv.cls.size(); j++) {
//				ThreadedHandler temp=this.crsv.cls.get(j);
//				if (temp!=this)
//				{
//					this.dos.writeUTF("Join,"+temp.name);
//				}
//				temp.dos.writeUTF("Join,"+this.name);
//            }

				// Nháº­n vÃ  gá»­i thÃ´ng Ä‘iá»‡p
				while (true) {
					dataInput = dis.readLine();
					if (dataInput != null) {
						System.out.println("Handle text message: " + dataInput);
						cmd = dataInput.substring(0, dataInput.indexOf("_"));
						msg = dataInput.substring(dataInput.indexOf("_") + 1);
						if (cmd.equals("msg")) {
							this.server.messageList.add(msg);

							// send back for other user
							for (int i = 0; i < this.server.cls.size(); i++) {
								this.server.cls.get(i).dos.writeBytes(msg);
							}
						} else if (cmd.equals("file")) {

							this.server.files.add(dataInput);

							System.out.println("Handle file message.");
//							System.out.println("File data: " + tempInt.size());

							for (int i = 0; i < this.server.cls.size(); i++) {
								System.out.println("\nResend file to client.");
								this.server.cls.get(i).dos.writeBytes(dataInput.split("_")[1]);
							}

						} else if (cmd.equals("userOut")) {
							incoming.close();
							this.server.cls.remove(this);
							System.out.println("User out");
						}
					}

				}
			} catch (SocketException socketEx) {
				System.out.println("Close socket: " + socketEx);
				server.cls.remove(this);
			} catch (IOException e) {
				System.out.print("Undefined exception: " + e);
				server.cls.remove(this);
			}
		} // ChÆ°a thá»±c thi
	}
}
