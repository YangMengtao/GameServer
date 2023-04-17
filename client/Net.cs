using System;
using System.Net.Sockets;
using UnityEngine;
using LitJson;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;

public class Net : MonoBehaviour
{
    private const int PORT = 3636;
    private const string HOST = "192.168.16.18";
    private const int BUFFER_SIZE = 1024;

    private Socket m_Socket;
    private byte[] m_Buffer = new byte[BUFFER_SIZE];

    public void OnConnect()
    {
        m_Socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
        m_Socket.BeginConnect(HOST, PORT, new AsyncCallback(ConnectCallback), null);
    }

    private void ConnectCallback(IAsyncResult ar)
    {
        try
        {
            m_Socket.EndConnect(ar);
            Debug.Log("Successfully connected to Skynet server");

            // Send a message to the server
            JObject json = new JObject();
            json.Add("cmd", "login");
            json.Add("username", "aaaa");
            json.Add("password", "123456");
            string jsonStr = JsonConvert.SerializeObject(json);
            byte[] data = System.Text.Encoding.ASCII.GetBytes(jsonStr);
            m_Socket.BeginSend(data, 0, data.Length, SocketFlags.None, new AsyncCallback(SendCallback), null);

            // Start receiving messages from the server
            m_Socket.BeginReceive(m_Buffer, 0, BUFFER_SIZE, SocketFlags.None, new AsyncCallback(ReceiveCallback), null);
        }
        catch (SocketException e)
        {
            Debug.Log("Unable to connect to Skynet server: " + e.ToString());
        }
    }

    private void SendCallback(IAsyncResult ar)
    {
        int bytesSent = m_Socket.EndSend(ar);
        Debug.Log("Sent " + bytesSent + " bytes to server");
    }

    private void ReceiveCallback(IAsyncResult ar)
    {
        try
        {
            int bytesRead = m_Socket.EndReceive(ar);
            if (bytesRead > 0)
            {
                string message = System.Text.Encoding.ASCII.GetString(m_Buffer, 0, bytesRead);
                Debug.Log("Received message from server: " + message);
                // Start receiving more messages from the server
                m_Socket.BeginReceive(m_Buffer, 0, BUFFER_SIZE, SocketFlags.None, new AsyncCallback(ReceiveCallback), null);
            }
        }
        catch (SocketException e)
        {
            Debug.Log("Unable to receive message from Skynet server: " + e.ToString());
        }
    }
}
