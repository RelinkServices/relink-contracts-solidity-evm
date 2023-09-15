/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumber,
  BigNumberish,
  BytesLike,
  CallOverrides,
  ContractTransaction,
  Overrides,
  PayableOverrides,
  PopulatedTransaction,
  Signer,
  utils,
} from "ethers";
import type {
  FunctionFragment,
  Result,
  EventFragment,
} from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type {
  TypedEventFilter,
  TypedEvent,
  TypedListener,
  OnEvent,
  PromiseOrValue,
} from "../../common";

export interface IChainlinkVRFv2DirectFundingProxyInterface
  extends utils.Interface {
  functions: {
    "callbackWithRandomness(uint8[],bytes32[],bytes32[],address,uint256,bytes32,uint256[])": FunctionFragment;
    "callingContracts(bytes32)": FunctionFragment;
    "requestHandled(bytes32)": FunctionFragment;
    "requestRandomness(uint32,uint16,uint32)": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "callbackWithRandomness"
      | "callingContracts"
      | "requestHandled"
      | "requestRandomness"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "callbackWithRandomness",
    values: [
      PromiseOrValue<BigNumberish>[],
      PromiseOrValue<BytesLike>[],
      PromiseOrValue<BytesLike>[],
      PromiseOrValue<string>,
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BytesLike>,
      PromiseOrValue<BigNumberish>[]
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "callingContracts",
    values: [PromiseOrValue<BytesLike>]
  ): string;
  encodeFunctionData(
    functionFragment: "requestHandled",
    values: [PromiseOrValue<BytesLike>]
  ): string;
  encodeFunctionData(
    functionFragment: "requestRandomness",
    values: [
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BigNumberish>
    ]
  ): string;

  decodeFunctionResult(
    functionFragment: "callbackWithRandomness",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "callingContracts",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "requestHandled",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "requestRandomness",
    data: BytesLike
  ): Result;

  events: {
    "RandomnessRequest(address,address,uint256,bytes32,uint32,uint16,uint32)": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "RandomnessRequest"): EventFragment;
}

export interface RandomnessRequestEventObject {
  user: string;
  dapp: string;
  nonce: BigNumber;
  requestId: string;
  _callbackGasLimit: number;
  _requestConfirmations: number;
  _numWords: number;
}
export type RandomnessRequestEvent = TypedEvent<
  [string, string, BigNumber, string, number, number, number],
  RandomnessRequestEventObject
>;

export type RandomnessRequestEventFilter =
  TypedEventFilter<RandomnessRequestEvent>;

export interface IChainlinkVRFv2DirectFundingProxy extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: IChainlinkVRFv2DirectFundingProxyInterface;

  queryFilter<TEvent extends TypedEvent>(
    event: TypedEventFilter<TEvent>,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TEvent>>;

  listeners<TEvent extends TypedEvent>(
    eventFilter?: TypedEventFilter<TEvent>
  ): Array<TypedListener<TEvent>>;
  listeners(eventName?: string): Array<Listener>;
  removeAllListeners<TEvent extends TypedEvent>(
    eventFilter: TypedEventFilter<TEvent>
  ): this;
  removeAllListeners(eventName?: string): this;
  off: OnEvent<this>;
  on: OnEvent<this>;
  once: OnEvent<this>;
  removeListener: OnEvent<this>;

  functions: {
    callbackWithRandomness(
      sigV: PromiseOrValue<BigNumberish>[],
      sigR: PromiseOrValue<BytesLike>[],
      sigS: PromiseOrValue<BytesLike>[],
      requestOrigin: PromiseOrValue<string>,
      chainId: PromiseOrValue<BigNumberish>,
      requestId: PromiseOrValue<BytesLike>,
      randomWords: PromiseOrValue<BigNumberish>[],
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    callingContracts(
      requestId: PromiseOrValue<BytesLike>,
      overrides?: CallOverrides
    ): Promise<[string] & { callingContract: string }>;

    requestHandled(
      requestId: PromiseOrValue<BytesLike>,
      overrides?: CallOverrides
    ): Promise<[boolean] & { handled: boolean }>;

    requestRandomness(
      _callbackGasLimit: PromiseOrValue<BigNumberish>,
      _requestConfirmations: PromiseOrValue<BigNumberish>,
      _numWords: PromiseOrValue<BigNumberish>,
      overrides?: PayableOverrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;
  };

  callbackWithRandomness(
    sigV: PromiseOrValue<BigNumberish>[],
    sigR: PromiseOrValue<BytesLike>[],
    sigS: PromiseOrValue<BytesLike>[],
    requestOrigin: PromiseOrValue<string>,
    chainId: PromiseOrValue<BigNumberish>,
    requestId: PromiseOrValue<BytesLike>,
    randomWords: PromiseOrValue<BigNumberish>[],
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  callingContracts(
    requestId: PromiseOrValue<BytesLike>,
    overrides?: CallOverrides
  ): Promise<string>;

  requestHandled(
    requestId: PromiseOrValue<BytesLike>,
    overrides?: CallOverrides
  ): Promise<boolean>;

  requestRandomness(
    _callbackGasLimit: PromiseOrValue<BigNumberish>,
    _requestConfirmations: PromiseOrValue<BigNumberish>,
    _numWords: PromiseOrValue<BigNumberish>,
    overrides?: PayableOverrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  callStatic: {
    callbackWithRandomness(
      sigV: PromiseOrValue<BigNumberish>[],
      sigR: PromiseOrValue<BytesLike>[],
      sigS: PromiseOrValue<BytesLike>[],
      requestOrigin: PromiseOrValue<string>,
      chainId: PromiseOrValue<BigNumberish>,
      requestId: PromiseOrValue<BytesLike>,
      randomWords: PromiseOrValue<BigNumberish>[],
      overrides?: CallOverrides
    ): Promise<void>;

    callingContracts(
      requestId: PromiseOrValue<BytesLike>,
      overrides?: CallOverrides
    ): Promise<string>;

    requestHandled(
      requestId: PromiseOrValue<BytesLike>,
      overrides?: CallOverrides
    ): Promise<boolean>;

    requestRandomness(
      _callbackGasLimit: PromiseOrValue<BigNumberish>,
      _requestConfirmations: PromiseOrValue<BigNumberish>,
      _numWords: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<string>;
  };

  filters: {
    "RandomnessRequest(address,address,uint256,bytes32,uint32,uint16,uint32)"(
      user?: PromiseOrValue<string> | null,
      dapp?: PromiseOrValue<string> | null,
      nonce?: PromiseOrValue<BigNumberish> | null,
      requestId?: null,
      _callbackGasLimit?: null,
      _requestConfirmations?: null,
      _numWords?: null
    ): RandomnessRequestEventFilter;
    RandomnessRequest(
      user?: PromiseOrValue<string> | null,
      dapp?: PromiseOrValue<string> | null,
      nonce?: PromiseOrValue<BigNumberish> | null,
      requestId?: null,
      _callbackGasLimit?: null,
      _requestConfirmations?: null,
      _numWords?: null
    ): RandomnessRequestEventFilter;
  };

  estimateGas: {
    callbackWithRandomness(
      sigV: PromiseOrValue<BigNumberish>[],
      sigR: PromiseOrValue<BytesLike>[],
      sigS: PromiseOrValue<BytesLike>[],
      requestOrigin: PromiseOrValue<string>,
      chainId: PromiseOrValue<BigNumberish>,
      requestId: PromiseOrValue<BytesLike>,
      randomWords: PromiseOrValue<BigNumberish>[],
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    callingContracts(
      requestId: PromiseOrValue<BytesLike>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    requestHandled(
      requestId: PromiseOrValue<BytesLike>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    requestRandomness(
      _callbackGasLimit: PromiseOrValue<BigNumberish>,
      _requestConfirmations: PromiseOrValue<BigNumberish>,
      _numWords: PromiseOrValue<BigNumberish>,
      overrides?: PayableOverrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    callbackWithRandomness(
      sigV: PromiseOrValue<BigNumberish>[],
      sigR: PromiseOrValue<BytesLike>[],
      sigS: PromiseOrValue<BytesLike>[],
      requestOrigin: PromiseOrValue<string>,
      chainId: PromiseOrValue<BigNumberish>,
      requestId: PromiseOrValue<BytesLike>,
      randomWords: PromiseOrValue<BigNumberish>[],
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    callingContracts(
      requestId: PromiseOrValue<BytesLike>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    requestHandled(
      requestId: PromiseOrValue<BytesLike>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    requestRandomness(
      _callbackGasLimit: PromiseOrValue<BigNumberish>,
      _requestConfirmations: PromiseOrValue<BigNumberish>,
      _numWords: PromiseOrValue<BigNumberish>,
      overrides?: PayableOverrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;
  };
}