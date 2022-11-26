import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketException;
import java.util.Vector;

public class TCPServer
{
    public final static int daytimePort = 8300;
    public TCPServer()
    {
        ServerSocket theServer;
        Socket theConnection;
        try {
            System.out.println("Server running...");
            theServer = new ServerSocket(daytimePort);
            while (true) {
                theConnection = theServer.accept();
//				System.out.println("Have Connection!");
                new ThreadedHandler(this,theConnection).start();
            }
        }
        catch (IOException e)
        {
            System.err.println(e);
        }
    }
    public Vector<ThreadedHandler> cls = new Vector<ThreadedHandler>();
    public Vector<String> messages = new Vector<String>();
    public static void main(String[] args)
    {
        new TCPServer();
    }


    public class ThreadedHandler extends Thread
    {
        TCPServer crsv;
        public Socket incoming;
        public DataInputStream dis;
        public DataOutputStream dos;
        public String userJson;

        public ThreadedHandler(TCPServer crsv, Socket i)
        {
            this.crsv=crsv;
            this.incoming=i;
            try
            {
                this.dis = new DataInputStream(incoming.getInputStream());
                this.dos = new DataOutputStream(incoming.getOutputStream());
//            for (int j=0; j<this.crsv.cls.size(); j++) {
//
//            }
            }
            catch(IOException e){}
        }

        public void run()
        {
            String ch="";
            try
            {
                //Kiểm tra để thêm người tham gia
                ch = dis.readLine();
                System.out.println("Handle message: " + ch);
                String cmd=ch.substring(0, ch.indexOf("_"));
                String msg=ch.substring(ch.indexOf("_")+1);
                if (!cmd.equals("userIn")) incoming.close();
                System.out.println("\nNew member join: "+msg);
                this.userJson=msg;
                this.crsv.cls.add(this);
//			for (int j=0; j<this.crsv.cls.size(); j++) {
//				ThreadedHandler temp=this.crsv.cls.get(j);
//				if (temp!=this)
//				{
//					this.dos.writeUTF("Join,"+temp.name);
//				}
//				temp.dos.writeUTF("Join,"+this.name);
//            }

                //Nhận và gửi thông điệp
                while (true)
                {
                    ch = dis.readLine();
                    System.out.println("Handle message: " + ch);
                    cmd=ch.substring(0, ch.indexOf("_"));
                    msg=ch.substring(ch.indexOf("_")+1);
                    if (cmd.equals("msg"))
                    {
                        this.crsv.messages.add(msg);
                        for (int i=0;i<this.crsv.cls.size();i++)
                        {
//						ThreadedHandler temp=this.crsv.cls.get(i);
//						if (temp!=this)
//						{
//							temp.dos.writeBytes("msg,"+">>"+msg+"\n");
//						}
                            this.crsv.cls.get(i).dos.writeBytes(msg);
                        }
                    }
                    else
                    if (cmd.equals("userOut"))
                    {
                        incoming.close();
                        this.crsv.cls.remove(this);
                        System.out.println("User out");
                    }
                }
            }
            catch(SocketException socketEx) {
                System.out.println("Close socket: "+ socketEx);
                crsv.cls.remove(this);
            }
            catch (IOException e)
            {
                System.out.print("Undefined exception: " +e);
                crsv.cls.remove(this);
            }
        } //Chưa thực thi
    }
}


