## IPFS Lab

### Install IPFS

- Get a copy of the IPFS from https://dist.ipfs.io/#go-ipfs
- Extract the `tar.gz file tar -xvf` and run the `install.sh`

```
ipfs init
```

- Check out the quick-start
- In a new terminal window run

```
ipfs daemon
```

Check out your local interface on `http://localhost:5001/ipfs/`

### Configure IPFS

- You need to set your IPFS so that other software can connect

```
ipfs config \
--json \
API.HTTPHeaders.Access-Control-Allow-Origin \
'["*"]'
```

```
ipfs config \
--json \
API.HTTPHeaders.Access-Control-Allow-Methods \
'["PUT", "GET", "POST"]
```

### Try out IPFS

- Use the web interface
- Upload a file
- Display the reference in your browser by putting in your address bar `http://localhost:8080/ipfs/<your_has_code_here>`

### Connect to IPFS API

```
create-react-app ipfstest
npm install --save ipfs-http-client
```

In your `App.js`

```js
const ipfsClient = require("ipfs-http-client");
const ipfs = ipfsClient("http://localhost:5001");
const ver = await ipfs.version();
console.log("IPFS Version=", ver);
```

- To add a file use `add`

```
var hash = ""
for await (const result of ipfs.add(this.state.buffer)) {               
    console.log(result)
    hash = result.path
}
```

### Submission Requirements

* Write a NextJS / ReactJS app that can take an image file and it to IPFS
* Display the file in the app
* Commit the changes to **private** GitHub repository and give a read-only access to [@dhruvinparikh](https://github.com/dhruvinparikh)
* Submit the repository URL to the BB
