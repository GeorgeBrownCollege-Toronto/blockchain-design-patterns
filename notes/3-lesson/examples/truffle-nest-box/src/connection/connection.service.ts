import { Injectable } from '@nestjs/common';
import { ethers, Contract, ContractInterface, Signer } from 'ethers';

@Injectable()
export class ConnectionService {
  private provider = new ethers.providers.JsonRpcProvider();

  launchToContract(contractAddress: string, contractAbi: ContractInterface): Contract {
    return new Contract(contractAddress, contractAbi, this.provider);
  }

  getSigner(): Signer {
    return this.provider.getSigner(0);
  }
}
