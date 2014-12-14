using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace JA_proj.Messages
{
    class InvalidXmlMessage
    {
        public InvalidXmlMessage(string invalidMessage)
        {
            InvalidMessage = invalidMessage;
        }

        public string InvalidMessage { get; set; }

    }
}
