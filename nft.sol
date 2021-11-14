//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import '@jbx-protocol/contracts/contracts/v1/interfaces/ITerminalDirectory.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';

contract JuiceboxNFT is ERC721Enumerable {
  /**
    @dev A directory of a project's current Juicebox terminal to receive payments in.
    */
  ITerminalDirectory public immutable terminalDirectory;

  /**
    @dev The ID of the project having funds routed to from the NFT sales.
  */
  uint256 public immutable projectId;

  /**
   * @param _terminalDirectory A directory of a project's current Juicebox terminal to receive payments in.
   * @param _projectId The ID of the project having funds routed to from the NFT sales.
   */
  constructor(ITerminalDirectory _terminalDirectory, uint256 _projectId) {
    terminalDirectory = _terminalDirectory;
    projectId = _projectId;
  }

  /**
   * @param _tokenId Is the token to mint.
   * @param _to Is the address the token will be minted to.
   * @param _beneficiary Is the address that will receive the project's token that result from forwarding funds.
   * @param _memo A memo to send along with the payment that'll get emitted in the Juicebox event.
   */
  function mint(
    uint256 _tokenId,
    address _to,
    address _benenficiary,
    string _memo
  ) external payable {
    // Get a reference to the Juicebox terminal being used for the project.
    ITerminal _terminal = terminalDirectory.terminalOf(_projectId);

    // The project should be accepting funds.
    require(_terminal != ITerminal(address(0)), 'UNAVAILABLE');

    // Forward the funds to the project.
    _terminal.pay{value: msg.value}(
      _projectId,
      _beneficiary,
      _memo,
      // No need to prefer unclaimed token.
      false
    );

    // Mint the NFT
    _safeMint(_to, tokenId);
  }
}
